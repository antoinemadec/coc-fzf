#!/usr/bin/env python3

import argparse
from pynvim import attach

parser = argparse.ArgumentParser(
    description='connect to running Nvim to get CocAction("getWorkspaceSymbols", query)')
parser.add_argument('socket', help="returned by Nvim's v:servername")
parser.add_argument('channel', help="channel id of coc's client")
parser.add_argument('bufnr', help="Nvim buffer where query should be done")
parser.add_argument('query', help="query to pass to CocAction('getWorkspaceSymbols')")
args = parser.parse_args()

nvim = attach('socket', path=args.socket)
items = nvim.call('rpcrequest', int(args.channel), 'CocAction', 'getWorkspaceSymbols', args.query, int(args.bufnr))

if items is None or items is 0:
    print("")
    exit(0)

for item in items:
  lnum = item['location']['range']['end']['line'] + 1
  col = item['location']['range']['end']['character']
  filename = item['location']['uri'].replace('file://', '')
  print("{0} [{1}] {2} {3},{4}".format(item['name'], item['kind'], filename, lnum, col))
