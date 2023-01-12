module GraphGraphviz

using Graphs
using FillArrays, Colors

export to_graphviz

"""
    flip_edges(g::SimpleDiGraph)

Flip the direction of all edges in a graph.
"""
flip_edges(g::SimpleDiGraph) = SimpleDiGraph(g.ne, g.badjlist, g.fadjlist)

_graphviz_color(c) = c
_graphviz_color(c::Colors.Colorant) = "#" * lowercase(hex(c))
function _graphviz_color(c::Colors.RGBA)
    # HACK: For some reason, I don't know why, the alpha channel is encoded
    # differently in Graphviz than in Colors.jl. Graphviz expects the alpha
    # to be _last_ characters, while `hex(c)` encodes them in the two _first_
    # characters.
    h = lowercase(hex(c))
    return "#" * h[3:end] * h[1:2]
end


"""
    to_graphviz(g::SimpleDiGraph; kwargs...)

Convert the graph `g` to a GraphViz graph.
"""
function to_graphviz(
    g::AbstractGraph;
    filename="/tmp/graph.dot",
    format="png",
    display=false,
    nodenamer=i -> "n$(i)",
    labels=Fill(nothing, nv(g)),
    nodeshapes=Fill(nothing, nv(g)),
    nodefillcolors=Fill(nothing, nv(g)),
    nodeedgecolors=Fill(nothing, nv(g)),
)
    # If a single value is provided, assume this is to be used for every thing.
    labels = labels isa AbstractArray ? labels : Fill(labels, nv(g))
    nodeshapes = nodeshapes isa AbstractArray ? nodeshapes : Fill(nodeshapes, nv(g))
    nodefillcolors = nodefillcolors isa AbstractArray ? nodefillcolors : Fill(nodefillcolors, nv(g))
    nodeedgecolors = nodeedgecolors isa AbstractArray ? nodeedgecolors : Fill(nodeedgecolors, nv(g))

    open(filename, "w") do file
        write(file, "digraph {\n")
        # Add the nodes.
        for n in vertices(g)
            attributes = []

            # Fill color of the node.
            fillcolor = nodefillcolors[n]
            if !isnothing(fillcolor)
                push!(attributes, "style=filled")
                push!(attributes, "fillcolor=\"$(_graphviz_color(fillcolor))\"")
            end

            # Edge color of the node.
            nodeedgecolor = nodeedgecolors[n]
            isnothing(nodeedgecolor) || push!(attributes, "color=\"$(_graphviz_color(nodeedgecolor))\"")

            # Label of the node.
            label = labels[n]
            isnothing(label) || push!(attributes, "label=$(label)")

            # Shapes of the nodes.
            nodeshape = nodeshapes[n]
            isnothing(nodeshape) || push!(attributes, "shape=\"$(nodeshape)\"")

            # Join the attributes and write the node to file.
            attributes_str = join(attributes, ", ")
            write(file, "    $(nodenamer(n)) [$(attributes_str)]\n")
        end

        # Add the edges.
        for e in edges(g)
            i = src(e);
            j = dst(e);
            write(file, "    $(nodenamer(i)) -> $(nodenamer(j))\n")
        end
        write(file, "}")
    end

    # TODO: Use `GraphViz.jl`.
    # Run `dot` to produce output.
    run(pipeline(
        `dot -T$(format) $filename`,
        stdout="$(filename).$(format)"
    ))

    # Open if desired.
    if display
        run(`xdg-open $(filename).$(format)`, wait=false)
    end

    return "$(filename).$(format)"
end

end
