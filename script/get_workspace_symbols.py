#!/usr/bin/env python3

import argparse
import enum
from pynvim import attach

parser = argparse.ArgumentParser(
    description='connect to running Nvim to get CocAction("getWorkspaceSymbols", query)')
parser.add_argument('socket', help="returned by Nvim's v:servername")
parser.add_argument('channel', help="channel id of coc's client")
parser.add_argument('bufnr', help="Nvim buffer where query should be done")
parser.add_argument('query', help="query to pass to CocAction('getWorkspaceSymbols')")
args = parser.parse_args()

# https://docs.microsoft.com/en-us/dotnet/api/microsoft.visualstudio.languageserver.protocol.completionitemkind
class Kind(enum.Enum):
    Class         = 7
    Color         = 16
    Constant      = 21
    Constructor   = 4
    Enum          = 13
    EnumMember    = 20
    Event         = 23
    Field         = 5
    File          = 17
    Folder        = 19
    Function      = 3
    Interface     = 8
    Keyword       = 14
    Method        = 2
    Module        = 9
    Operator      = 24
    Property      = 10
    Reference     = 18
    Snippet       = 15
    Struct        = 22
    Text          = 1
    TypeParameter = 25
    Unit          = 11
    Value         = 12
    Variable      = 6

nvim = attach('socket', path=args.socket)
items = nvim.call('rpcrequest', int(args.channel), 'CocAction', 'getWorkspaceSymbols', args.query, int(args.bufnr))

if items is None or items is 0:
    print("")
    exit(0)

for item in items:
  lnum = item['location']['range']['end']['line'] + 1
  col = item['location']['range']['end']['character']
  filename = item['location']['uri'].replace('file://', '')
  print("{0} [{1}] {2} {3},{4}".format(item['name'], Kind(item['kind']).name, filename, lnum, col))
