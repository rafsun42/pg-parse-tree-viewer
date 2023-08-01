import json

def json_to_print(parse_tree_json:str, ind:int=0):
    pt = json.loads(parse_tree_json)

    match pt["type"]:
        case "QUERY":
            print_query(pt, ind)
        case _:
            print("ERROR: Unknown type")


def print_query(pt, ind:int):
    print(pt['type'])

def print_ind(int):
    print(int*' ')
