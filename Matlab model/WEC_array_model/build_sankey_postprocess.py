import json
import os
import sys


def fmt_watts(value):
    return f"{value:.2f} W"


def build_labels(wec):
    return [
        f"Incident Wave : {fmt_watts(wec['P_inc'])}",
        f"Absorbed : {fmt_watts(wec['P_abs'])}",
        f"Not Absorbed : {fmt_watts(wec['P_not'])}",
        f"Radiated : {fmt_watts(wec['P_rad'])}",
        f"PTO Elec : {fmt_watts(wec['P_pto'])}",
        f"Delivered Elec : {fmt_watts(wec['P_del'])}",
        f"Elec Loss (Cable) : {fmt_watts(wec['P_loss'])}",
    ]


def build_links():
    # Node order:
    # 0 Incident, 1 Absorbed, 2 Not Absorbed, 3 Radiated, 4 PTO, 5 Delivered, 6 Loss
    source = [0, 0, 1, 1, 4, 4]
    target = [1, 2, 4, 3, 5, 6]
    return source, target


def build_positions():
    # Node order:
    # 0 Incident, 1 Absorbed, 2 Not Absorbed, 3 Radiated, 4 PTO, 5 Delivered, 6 Loss
    x = [0.0, 0.33, 0.33, 0.66, 0.66, 1.0, 1.0]
    y = [0.5, 0.3, 0.85, 0.65, 0.25, 0.2, 0.85]
    return x, y


def plot_sankey(wec, title, outfile):
    labels = build_labels(wec)
    source, target = build_links()
    x, y = build_positions()
    values = [
        wec["P_abs"],
        wec["P_not"],
        wec["P_pto"],
        wec["P_rad"],
        wec["P_del"],
        wec["P_loss"],
    ]
    link_colors = [
        "rgba(31,119,180,0.65)",  # absorbed
        "rgba(127,127,127,0.55)",  # not absorbed
        "rgba(44,160,44,0.65)",   # PTO elec
        "rgba(255,127,14,0.6)",   # radiated
        "rgba(23,190,207,0.7)",   # delivered
        "rgba(214,39,40,0.7)",    # loss
    ]
    node_colors = [
        "rgba(31,119,180,0.85)",
        "rgba(31,119,180,0.85)",
        "rgba(127,127,127,0.75)",
        "rgba(255,127,14,0.75)",
        "rgba(44,160,44,0.85)",
        "rgba(23,190,207,0.85)",
        "rgba(214,39,40,0.85)",
    ]

    try:
        import plotly.graph_objects as go
    except Exception as exc:
        raise RuntimeError(
            "Plotly is required for Sankey PNG export. "
            "Install with: pip install plotly kaleido"
        ) from exc

    fig = go.Figure(
        data=[
            go.Sankey(
                arrangement="fixed",
                node=dict(
                    label=labels,
                    pad=20,
                    thickness=22,
                    line=dict(color="black", width=0.5),
                    color=node_colors,
                    x=x,
                    y=y,
                ),
                link=dict(
                    source=source,
                    target=target,
                    value=values,
                    color=link_colors,
                ),
            )
        ]
    )
    fig.update_layout(
        title_text=title,
        font_size=30,
        width=1900,
        height=500,
        margin=dict(l=20, r=20, t=100, b=50),
    )

    try:
        import plotly.io as pio
        pio.kaleido.scope.default_format = "png"
        fig.write_image(outfile, scale=2)
    except Exception as exc:
        html_out = os.path.splitext(outfile)[0] + ".html"
        fig.write_html(html_out)
        print(
            "Warning: PNG export failed; wrote HTML instead. "
            "Install/upgrade kaleido for PNG support. "
            f"Details: {exc}"
        )


def main():
    if "json_path" in globals() and globals()["json_path"]:
        path = globals()["json_path"]
    elif len(sys.argv) > 1 and sys.argv[1]:
        path = sys.argv[1]
    else:
        path = os.path.join(os.getcwd(), "sankey_data.json")

    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    plot_sankey(data["wec1"], "Sankey – WEC1", "Sankey_WEC1.png")
    plot_sankey(data["wec2"], "Sankey – WEC2", "Sankey_WEC2.png")


if __name__ == "__main__":
    main()
