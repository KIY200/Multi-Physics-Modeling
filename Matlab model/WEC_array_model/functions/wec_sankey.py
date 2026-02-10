# -*- coding: utf-8 -*-
"""
Created on Tue Feb  3 03:29:20 2026

@author: shifat
"""

import matplotlib.pyplot as plt
import matplotlib.patheffects as path_effects
from matplotlib.sankey import Sankey
import numpy as np

def make_sankey(incident, absorbed, pto, delivered, elec_loss, outpath, wec_label="WEC"):
    # Derived losses
    unabsorbed   = incident - absorbed
    non_pto_loss = absorbed - pto

    fig = plt.figure(figsize=(14, 4), facecolor="white")
    ax = fig.add_subplot(1, 1, 1, facecolor="white")
    ax.set_xticks([]); ax.set_yticks([])

    title = ax.set_title(
        f"{wec_label} Power Flow (Sankey)\n"
        "Incident: {:.2f} W | Absorbed: {:.2f} W | "
        "PTO: {:.2f} W | Delivered: {:.2f} W | Loss: {:.2f} W".format(
            incident, absorbed, pto, delivered, elec_loss
        ),
        color="black", fontsize=16, pad=12
    )
    title.set_path_effects([
        path_effects.Stroke(linewidth=3, foreground="white"),
        path_effects.Normal()
    ])

    sankey = Sankey(
        ax=ax,
        unit=" W",
        format="%.2f",
        head_angle=135,
        gap=0.35,
        scale=1/60,
        offset=0.1
    )

    sankey.add(
        patchlabel=None,
        flows=[incident, -absorbed, -unabsorbed],
        orientations=[0, 0, -1],
        labels=[f"Wave Power", "Absorbed", "Unabsorbed/Reflected"],
        pathlengths=[1.2, 1.2, 1.8],
        facecolor="#2e6bd1",
        edgecolor="black",
        linewidth=1.2
    )

    sankey.add(
        patchlabel=" ",
        flows=[absorbed, -pto, -non_pto_loss],
        orientations=[0, 0, -1],
        labels=[None, "PTO", "Non-PTO Loss"],
        pathlengths=[0.8, 1.2, 2.0],
        prior=0,
        connect=(1, 0),
        facecolor="#f5a623",
        edgecolor="black",
        linewidth=1.2
    )

    sankey.add(
        patchlabel=" ",
        flows=[pto, -delivered, -elec_loss],
        orientations=[0, 0, -1],
        labels=[None, "Delivered", "Electrical Loss"],
        pathlengths=[0.8, 1.4, 2.4],
        prior=1,
        connect=(1, 0),
        facecolor="#2ca02c",
        edgecolor="black",
        linewidth=1.2
    )

    diagrams = sankey.finish()

    for d in diagrams:
        for t in d.texts:
            t.set_fontsize(13)
            stroke = 3
            t.set_path_effects([
                path_effects.Stroke(linewidth=stroke, foreground="white"),
                path_effects.Normal()
            ])

    fig.savefig(outpath, dpi=300, bbox_inches="tight")
    plt.close(fig)

    return outpath
