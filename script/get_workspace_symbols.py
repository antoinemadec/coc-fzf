#!/usr/bin/env python3

import argparse
from pynvim import attach

parser = argparse.ArgumentParser(
    description='connect to running Nvim to get CocAction("getWorkspaceSymbols", query)')
parser.add_argument('socket', help="returned by Nvim's v:servername")
parser.add_argument('bufnr', help="Nvim buffer where query should be done")
parser.add_argument('query', help="query to pass to CocAction('getWorkspaceSymbols')")
args = parser.parse_args()

nvim = attach('socket', path=args.socket)

# floating windows are messed-up when using :buffer
# workaround: use nvim_open_win(bufnr) and nvim_win_close()
win = nvim.api.open_win(2, 1, {'relative':'editor', 'width':1, 'height':1, 'row':0, 'col':0})
items = nvim.call('CocAction', 'getWorkspaceSymbols', args.query)
cwd = nvim.call('getcwd') + '/'
nvim.api.win_close(win, 1)
nvim.api.input('i')

if items is None or items is 0:
    print("")
    exit(0)

for item in items:
  lnum = item['location']['range']['end']['line'] + 1
  col = item['location']['range']['end']['character']
  filename = item['location']['uri'].replace('file://', '').replace(cwd, '')
  print("{0} [{1}] {2} {3},{4}".format(item['name'], item['kind'], filename, lnum, col))
