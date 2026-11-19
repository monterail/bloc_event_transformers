#!/usr/bin/env node
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
const execute = promisify(execFile);
let input = ''; for await (const chunk of process.stdin) input += chunk;
const data = JSON.parse(input);
const repository = process.env.GITHUB_REPOSITORY, base = process.env.GITHUB_BASE_BRANCH, token = process.env.GH_TOKEN;
const code = data.artifact.code;
if (!repository || !/^[\w.-]+\/[\w.-]+$/.test(repository) || repository.includes('..') || !base || !/^[\w][\w./-]*$/.test(base) || base.includes('..') ||
    !token || /[\r\n\0]/.test(token) || data.artifact.kind !== 'code' || data.artifact.path !== '/delivery/artifact' ||
    !code || !/^[a-f0-9]{40}(?:[a-f0-9]{24})?$/.test(code.commit) || !/^[a-f0-9]{40}(?:[a-f0-9]{24})?$/.test(code.baseCommit) ||
    !/^montecito\/[a-z0-9_.-]+-[a-f0-9-]{36}$/.test(code.branch)) throw new Error('Invalid GitHub writer input');
const directory = await mkdtemp(join(tmpdir(), 'montecito-pr-'));
const env = { PATH: process.env.PATH, HOME: directory, LANG: 'C.UTF-8', GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: '/dev/null', GIT_TERMINAL_PROMPT: '0', GH_HOST: 'github.com', GH_CONFIG_DIR: join(directory, 'gh'), GH_TOKEN: token };
const run = async (cmd, args) => (await execute(cmd, args, { cwd: directory, env, encoding: 'utf8', timeout: 60000, maxBuffer: 1048576 })).stdout;
const gh = args => run('gh', args);
const git = args => run('git', ['-c', 'core.hooksPath=/dev/null', '-c', 'credential.helper=', ...args]);
const url = value => {
  const u = new URL(value);
  if (u.origin !== 'https://github.com' || u.username || u.password || u.search || u.hash ||
      !/^\/[^/]+\/[^/]+\/pull\/\d+$/.test(u.pathname) || u.pathname.split('/').slice(1, 3).join('/').toLowerCase() !== repository.toLowerCase()) throw new Error('Invalid PR URL');
  return u.href;
};
const existing = async () => {
  const items = JSON.parse(await gh(['pr', 'list', '--repo', repository, '--head', code.branch, '--base', base, '--state', 'all', '--json', 'url,headRefOid', '--limit', '100']));
  if (!Array.isArray(items)) throw new Error('Invalid PR lookup');
  if (!items.length) return;
  const matching = items.find(x => x.headRefOid === code.commit);
  if (!matching) throw new Error('Existing PR differs from saved code');
  return url(matching.url);
};
try {
  let result = await existing();
  if (!result) {
    await git(['init', '--bare', 'repo']); const repo = ['-C', join(directory, 'repo')];
    await writeFile(join(directory, 'token'), token + '\n', { mode: 0o600 });
    await writeFile(join(directory, 'askpass'), '#!/bin/sh\ncase "$1" in *Username*) echo x-access-token;; *) cat "$HOME/token";; esac\n', { mode: 0o700 });
    env.GIT_ASKPASS = join(directory, 'askpass');
    await git([...repo, 'fetch', '--no-tags', '--', `https://github.com/${repository}.git`, code.baseCommit]);
    await git([...repo, 'fetch', '--no-tags', data.artifact.path, `refs/heads/${code.branch}:refs/heads/${code.branch}`]);
    if ((await git([...repo, 'rev-parse', `refs/heads/${code.branch}`])).trim() !== code.commit) throw new Error('Bundle revision mismatch');
    await git([...repo, 'push', '--', `https://github.com/${repository}.git`, `refs/heads/${code.branch}:refs/heads/${code.branch}`]);
    const body = join(directory, 'body.md');
    await writeFile(body, `${data.request.body ?? data.summary}\n\nMontecito run: ${data.runId}\nDelivery: ${data.deliveryId}\n`, { mode: 0o600 });
    try {
      result = url((await gh(['pr', 'create', '--repo', repository, '--base', base, '--head', code.branch,
        '--title', data.request.title ?? `${data.ticketId}: ${data.summary.replace(/[\r\n]/g, ' ').slice(0, 140)}`, '--body-file', body])).trim());
    } catch { result = await existing(); if (!result) throw new Error('PR creation failed'); }
  }
  console.log(JSON.stringify({ url: result }));
} catch { console.error('GitHub PR writer failed; retry the saved delivery.'); process.exitCode = 1; }
finally { await rm(directory, { recursive: true, force: true }); }
