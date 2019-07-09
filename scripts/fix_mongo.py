#!/usr/bin/env python3
"""
Author : kyclark
Date   : 2019-07-08
Purpose: Fix MongoDB
"""

import argparse
import os
import re
import sys
from pymongo import MongoClient



# --------------------------------------------------
def get_args():
    """Get command-line arguments"""

    parser = argparse.ArgumentParser(
        description='Fix MongoDB',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('-d',
                        '--db',
                        help='MongoDB name',
                        metavar='str',
                        type=str,
                        default='b2_project')

    parser.add_argument('-u',
                        '--url',
                        help='MongoDB URL',
                        metavar='str',
                        type=str,
                        default='mongodb://localhost:27017/')

    # parser.add_argument('-i',
    #                     '--int',
    #                     help='A named integer argument',
    #                     metavar='int',
    #                     type=int,
    #                     default=0)

    # parser.add_argument('-f',
    #                     '--flag',
    #                     help='A boolean flag',
    #                     action='store_true')

    return parser.parse_args()


# --------------------------------------------------
def normalize_name(s: str) -> str:
    """Consistent name"""

    # CamelCase -> Camel_Case
    s = re.sub(r'(?<=[a-z])([A-Z])', r'_\1', s)
    return re.sub(r'[\s-]', '_', s.lower())


# --------------------------------------------------
def test_normalize_name():
    """Test"""

    assert normalize_name('SampleID') == 'sample_id'
    assert normalize_name('sample_ID') == 'sample_id'
    assert normalize_name('SAMPLE-ID') == 'sample_id'
    assert normalize_name('sample id') == 'sample_id'

# --------------------------------------------------
def main():
    """Make a jazz noise here"""

    args = get_args()
    client = MongoClient(args.url)
    db = client[args.db]

    fix_experiment(db)

    print('Done.')


# --------------------------------------------------
def fix_experiment(db):
    """Fix experiment"""

    exp_orig_coll = db['experiment_orig']
    exp_result_coll = db['experiment_result']
    exp_coll = db['experiment']

    for i, exp in enumerate(exp_orig_coll.find(), start=1):
        sample_id = exp['sample_ID']
        print('{:3}: {}'.format(i, sample_id))

        if 'Result' in exp:
            result = dict(exp['Result'])

            if not exp_result_coll.find_one({'sample_id': sample_id}):
                result['sample_id'] = sample_id
                exp_result_coll.insert_one(result)

            exp.pop('Result')

        if 'files' in exp:
            exp.pop('files')

        exp_doc = {}
        for key, value in exp.items():
            exp_doc[normalize_name(key)] = value

        if not exp_coll.find_one({'sample_id': sample_id}):
            exp_coll.insert_one(exp_doc)

# --------------------------------------------------
if __name__ == '__main__':
    main()
