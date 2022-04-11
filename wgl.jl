### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 5ae60086-7fb3-11ec-259d-a1dd2769199a
begin
	import Pkg
	Pkg.activate(Base.current_project())
	using Images, Colors, Lazy, PlutoUI, HypertextLiteral
end

# ╔═╡ 82ab7cd4-8ec8-4b01-a5d7-d7c82b0d1080
@bind color Slider(0:.01:1.0)

# ╔═╡ 68fd8813-c5ba-488e-b020-2c72cc35aea4
@htl("""
<script src="https://npmcdn.com/regl/dist/regl.min.js"></script>
<script id="foo">
	//# sourceURL=foo.js
    const node = this ?? document.createElement("div")

    if (this == null) {
		node.style.width = "600px"
		node.style.height = "400px"
        console.log("Setup")
        node.regl = createREGL(node)
		node.drawTriangle = node.regl({
		  frag: `
		  void main() {
		    gl_FragColor = vec4(1, 0, 0, 1);
		  }`,
		
		  vert: `
		  attribute vec2 position;
		  void main() {
		    gl_Position = vec4(position, 0, 1);
		  }`,
		
		  attributes: {
		    position: [[0, -1], [-1, 0], [1, 1]]
		  },
		
		  count: 3
		})
    }
    console.log("Main body")
    node.regl.clear({
        color: [0, $(color), 1, 1]
     })
	node.drawTriangle()
    return node
</script>
""")

# ╔═╡ 05e21459-9e0e-4671-9848-c032e58cb0b1
md"""
TODO
-----------
- Understand regl
   - frame function
- picogl
- pure webgl

"""

# ╔═╡ Cell order:
# ╠═5ae60086-7fb3-11ec-259d-a1dd2769199a
# ╠═82ab7cd4-8ec8-4b01-a5d7-d7c82b0d1080
# ╠═68fd8813-c5ba-488e-b020-2c72cc35aea4
# ╠═05e21459-9e0e-4671-9848-c032e58cb0b1
