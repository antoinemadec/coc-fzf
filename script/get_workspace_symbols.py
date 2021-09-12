#!/usr/bin/env python3

import argparse
import re
from urllib.parse import unquote

from pynvim import attach


# --------------------------------------------------------------
# functions
# --------------------------------------------------------------
kind_dict = {}
kind_dict[1] = 'File'
kind_dict[2] = 'Module'
kind_dict[3] = 'Namespace'
kind_dict[4] = 'Package'
kind_dict[5] = 'Class'
kind_dict[6] = 'Method'
kind_dict[7] = 'Property'
kind_dict[8] = 'Field'
kind_dict[9] = 'Constructor'
kind_dict[10] = 'Enum'
kind_dict[11] = 'Interface'
kind_dict[12] = 'Function'
kind_dict[13] = 'Variable'
kind_dict[14] = 'Constant'
kind_dict[15] = 'String'
kind_dict[16] = 'Number'
kind_dict[17] = 'Boolean'
kind_dict[18] = 'Array'
kind_dict[19] = 'Object'
kind_dict[20] = 'Key'
kind_dict[21] = 'Null'
kind_dict[22] = 'EnumMember'
kind_dict[23] = 'Struct'
kind_dict[24] = 'Event'
kind_dict[25] = 'Operator'
kind_dict[26] = 'TypeParameter'


def get_kind(val):
    return kind_dict.get(val, 'Unkown')


def get_exclude_re_patterns(symbol_excludes):
    re_patterns = []
    for pattern in symbol_excludes:
        re_pattern = re.sub(r'\.', r'\.', pattern)
        re_pattern = re.sub(r'\*\*', r'.|', re_pattern)
        re_pattern = re.sub(r'\*', r'[^/]*', re_pattern)
        re_pattern = re.sub(r'\|', r'*', re_pattern)
        re_patterns.append(re_pattern)
    return re_patterns


def file_is_excluded(filename, exclude_re_patterns):
    for pattern in exclude_re_patterns:
        if re.match(pattern, filename):
            return True
    return False


# --------------------------------------------------------------
# execution
# --------------------------------------------------------------
parser = argparse.ArgumentParser(
    description='connect to running Nvim to get CocAction("getWorkspaceSymbols", query)')
parser.add_argument('socket', help="returned by Nvim's v:servername")
parser.add_argument('bufnr', help="Nvim buffer where query should be done")
parser.add_argument(
    'query', help="query to pass to CocAction('getWorkspaceSymbols')")
parser.add_argument('ansi_typedef', help="ansi code for highlight Typedef")
parser.add_argument('ansi_comment', help="ansi code for highlight Comment")
parser.add_argument('ansi_ignore', help="ansi code for highlight Ignore")
parser.add_argument('symbol_excludes', help="Coc config symbol excludes list")
parser.add_argument(
    '--kind', nargs=1, help='only search for a specific "kind" (class, function, etc)')
args = parser.parse_args()

nvim = attach('socket', path=args.socket)

items = nvim.call('CocAction', 'getWorkspaceSymbols', args.query,
                  int(args.bufnr))
if items is None or len(items) == 0:
    exit(0)

symbol_excludes = eval(args.symbol_excludes)
exclude_re_patterns = get_exclude_re_patterns(symbol_excludes)

ignored_colon = args.ansi_ignore.replace('STRING', ':')

for item in items:
    lnum = item['location']['range']['start']['line'] + 1
    col = item['location']['range']['start']['character']
    filename = unquote(item['location']['uri'].replace('file://', ''))
    kind = get_kind(item['kind'])

    # filters
    if args.kind is not None and args.kind[0].lower() != kind.lower():
        continue
    if file_is_excluded(filename, exclude_re_patterns):
        continue

    name_with_ansi = item['name']
    kind_with_ansi = args.ansi_typedef.replace('STRING', '[' + kind + ']')
    filename_with_ansi = args.ansi_comment.replace('STRING', filename)
    lnum_col_with_ansi = args.ansi_ignore.replace('STRING',
                                                  ':' + str(lnum) + ':' + str(col))
    print("{0} {1}{2}{3}{4}".format(
        name_with_ansi, kind_with_ansi, ignored_colon, filename_with_ansi,
        lnum_col_with_ansi))
