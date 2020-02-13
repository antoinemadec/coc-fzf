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

# https://docs.microsoft.com/en-us/dotnet/api/microsoft.visualstudio.languageserver.protocol.completionitemkind
kind_dict = {}
kind_dict[7]  = 'Class'
kind_dict[16] = 'Color'
kind_dict[21] = 'Constant'
kind_dict[4]  = 'Constructor'
kind_dict[13] = 'Enum'
kind_dict[20] = 'EnumMember'
kind_dict[23] = 'Event'
kind_dict[5]  = 'Field'
kind_dict[17] = 'File'
kind_dict[19] = 'Folder'
kind_dict[3]  = 'Function'
kind_dict[8]  = 'Interface'
kind_dict[14] = 'Keyword'
kind_dict[2]  = 'Method'
kind_dict[9]  = 'Module'
kind_dict[24] = 'Operator'
kind_dict[10] = 'Property'
kind_dict[18] = 'Reference'
kind_dict[15] = 'Snippet'
kind_dict[22] = 'Struct'
kind_dict[1]  = 'Text'
kind_dict[25] = 'TypeParameter'
kind_dict[11] = 'Unit'
kind_dict[12] = 'Value'
kind_dict[6]  = 'Variable'

def get_kind(val):
    return kind_dict.get(val, 'Unkown')

nvim = attach('socket', path=args.socket)
items = nvim.call('rpcrequest', int(args.channel), 'CocAction', 'getWorkspaceSymbols', args.query, int(args.bufnr))

if items is None or items is 0:
    print("")
    exit(0)

for item in items:
  lnum = item['location']['range']['end']['line'] + 1
  col = item['location']['range']['end']['character']
  filename = item['location']['uri'].replace('file://', '')
  print("{0} [{1}] {2} {3},{4}".format(item['name'], get_kind(item['kind']), filename, lnum, col))
