import json
import os
import sys

from wec_sankey import make_sankey


def main():
    if "json_path" in globals() and globals()["json_path"]:
        path = globals()["json_path"]
    elif len(sys.argv) > 1 and sys.argv[1]:
        path = sys.argv[1]
    else:
        path = os.path.join(os.getcwd(), "sankey_data.json")

    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    project_dir = os.path.dirname(os.path.abspath(path))
    figures_dir = os.path.join(project_dir, "figures")
    os.makedirs(figures_dir, exist_ok=True)
    sankey1_path = os.path.join(figures_dir, "Sankey_WEC1.png")
    sankey2_path = os.path.join(figures_dir, "Sankey_WEC2.png")

    wec1 = data["wec1"]
    wec2 = data["wec2"]

    make_sankey(
        wec1["P_inc"],
        wec1["P_abs"],
        wec1["P_pto"],
        wec1["P_del"],
        wec1["P_loss"],
        sankey1_path,
        wec_label="WEC1",
    )
    make_sankey(
        wec2["P_inc"],
        wec2["P_abs"],
        wec2["P_pto"],
        wec2["P_del"],
        wec2["P_loss"],
        sankey2_path,
        wec_label="WEC2",
    )


if __name__ == "__main__":
    main()
