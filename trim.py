
# type -> list[fields]
# Retains all fields if not defined here
FIELD_FILTER = {
    'QUERY': [
        'rtable', 'jointree', 'targetList', 'sortClause',
    ],
    'VAR': [
         'varno', 'varattno', 'vartype'
    ],
    'TARGETENTRY': [
        'resno', 'resname', 'expr'
    ],
    'RTE': [
        'relid', 'relkind', 'rtekind', 'eref', 'subquery'
    ]
}

RTEKIND = [
    'RTE_RELATION',
    'RTE_JOIN',
    'RTE_FUNCTION',
    'RTE_TABLEFUNC',
    'RTE_VALUES',
    'RTE_CTE',
    'RTE_NAMEDTUPLESTORE'
]

def trim(elem):
    res = None

    if (type(elem) == list):
        newlist = []
        for item in elem:
            newlist.append(trim(item))
        res = newlist
    elif (type(elem) == dict):
        newobj = {
            'type': elem['type']
        }

        for key in elem.keys():
            if (elem['type'] not in FIELD_FILTER.keys()):
                # retain all fields, since no filter
                # defined for this type
                newobj[key] = trim(elem[key])
            else:
                if (key in FIELD_FILTER[elem['type']]):
                    newobj[key] = trim(elem[key])

            # newobj[key] = simplify_scalar(key, newobj[key])

        res = newobj
    else:
        res = elem

    return simplify(res)

def simplify(elem):
    if (type(elem) != dict):
        return elem

    match elem['type']:
        case 'ALIAS':
            return simplify_alias(elem)
        case _:
            return elem

def simplify_alias(alias):
    """
    {
        "type": "ALIAS",
        "aliasname": "X",
        "colnames": [
            "a",
            "b"
        ]
    }

    RETURNS: X (a, b,)
    """
    out = ""
    out += alias['aliasname']
    out += ' ('

    for colname in alias['colnames']:
        out += colname + ', '

    out += ')'
    return out

def simplify_scalar(key, value):
    if (key == 'rtekind'):
        return RTEKIND[value]
    else:
        return value
