### A Pluto.jl notebook ###
# v0.19.0

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

# ╔═╡ d4aff600-a14a-4c8e-b82e-f0df5c1c6302
begin
	import Pkg
	Pkg.activate(Base.current_project())
	using Images, Colors, Lazy, PlutoUI, HypertextLiteral
end
	

# ╔═╡ bda3607d-749c-4bc9-aee8-de02cc81bd96
function LAB➜RGB(color)
    convert(RGB{Float64}, Lab(color[1:3]...))::RGB{Float64}
end


# ╔═╡ 09f82874-4bd7-4ab8-aad6-bd33aa607b05
function createImage(shader::Function, w=400, h=400)
    img = Array{RGB{Float64}, 2}(undef, h, w)
	@Threads.threads for j=h:-1:1
		for i=1:w
			img[j,i] = LAB➜RGB(shader(i,j,w,h))
		end
	end
	img
end

# ╔═╡ 3bd1b4b1-f8c8-4720-96b8-55ebb76d155c
function sweep(hue) 
    hr = deg2rad(hue) 
    c  = cos(hr)
    s  = sin(hr)
    (i,j,w,h) -> [100*i/w, 100*j/h*c, 100*j/h*s]
end

# ╔═╡ bef89303-1433-4b91-8ccb-fb61da42cbc7
createImage(sweep(7))

# ╔═╡ 27e2f8f2-534a-4584-afbd-0e75f07ea046
begin
	red   = [ 42.5, 67.6, 56.7]
	white = [100.0,  0.0,  0.0]
	green = [ 35.0,-26.1, 15.1] #dark green
	black = [  0.0,  0.0,  0.0]
	yellow = [79.6,-18.1, 79.8]
	grey   = [21.2,  0.0,  0.0]
end

# ╔═╡ 818bc69d-79e0-4d27-9fef-569bc357654f
sl = @bind threadCount Slider(50:150, default=100)

# ╔═╡ c5b60867-85b2-4c0c-9606-ae3a2d04a7dd
begin
	createImage() do i,j,w,h
	    thread = mod(i-j,4) < 2           ? i % threadCount      : j % threadCount 
	    thread = thread > threadCount/2   ? threadCount - thread : thread          
	    color  = thread < 0.2*threadCount ? red    : 
	             thread < 0.3*threadCount ? yellow :                 
	                                        grey                    
	end
	
end

# ╔═╡ b55f864d-74c9-4ae6-8f72-8092469d3483
begin 
	stewart=[( 6, red   ) , 
	         (56, white ) ,
	         ( 6, black ) ,
	         ( 6, white ) ,
	         ( 6, black ) ,
	         ( 6, white ) ,
	         (26, green ) ,
	         (16, red   ) ,
	         ( 2, red ) ,
	         ( 2, red   ) ,
	         ( 2, white ) ,]
	
	function tartan(sett)
	    counts   = [x[1] for x=sett]
	    colors   = [x[2] for x=sett]
	    cumCount = cumsum(counts)
	    threadCount = 2*sum(counts);
	    (i,j,w,h) -> begin
			## 2/2 twill
	        thread = mod(i-j,4) < 2 ? i % threadCount : j % threadCount
			## symmetrize the pattern
	        thread = thread > threadCount/2 ? threadCount - thread : thread   
	        ## lookup color
			vec(colors[findfirst(thread .<= cumCount)])
	    end
	end
	
	createImage(tartan(stewart),536,536)
end

# ╔═╡ 048bde34-6542-4e5a-998e-298248759568
begin
		function weave(isWeftOnTop::Function, color::Function; threadWidth=1.0,margin=0.10, marginColor=[82.0, 0, 0])
	    (i,j,w,h) -> begin
	        i = i+0.5; j = j+0.5;  ##  №, I am not ☆ about this ❆
	        (weftId, weftRem)  = divrem(i,threadWidth)
	        (warpId, warpRem)  = divrem(j,threadWidth)            
	        weftOnTop = isWeftOnTop(weftId, warpId) 
	        remainder = weftOnTop ? weftRem : warpRem
	        fraction = remainder/threadWidth
	        fraction = fraction >= 0.5 ? 1.0-fraction : fraction ## symmetrize
	        fraction >= margin ? color(weftOnTop,weftId,warpId) : marginColor  
	    end
	end
	
	## zoom
	function zoom(shader::Function; center=[20.0,20.0], radius=120.0, scale=20.0)
	    (i,j,w,h) -> begin
	        p = [i,j]
	        s = norm(p-center) < radius ? scale : 1.0
	        p = center + (p-center)/s
	        shader(p[1], p[2],w,h)
	    end
	end
	
	simpleColors(isWeftOnTop, i, j) = isWeftOnTop ?  red : grey
	twill = (i,j) -> mod(i-j,4) < 2
	
	@> twill begin          ## @> is a threading macro from Lazy    
	   weave(simpleColors) 
	   zoom 
	   createImage 
	end
end

# ╔═╡ f84badfc-b516-45bc-b495-e0e91fb90e77
[RGB(0.0,g/100.0,b/100.0) for b=99:-1:0, g=0:99]

# ╔═╡ 51166cd4-831d-4a1d-9294-220dce71999b
f = begin
		
	function herring(i,j)
		n = 20
		x = mod(i, n)
		(x <  n/2) ? mod(i-j,4) < 2 : mod(i+j,4) < 2  
		
		#mod(x, 2) == 0
	end
	
	@> herring begin          ## @> is a threading macro from Lazy    
	   weave(simpleColors) 
	   #(f) -> (i,j,w,h) -> f(floor(Int, i/3), floor(Int, j/3), w, h)	
	   zoom(scale=15,radius=200) 
	   createImage 
	end
end

# ╔═╡ 7476507e-2e53-446e-9b34-0520c4e6efcf
@htl("<div>$(display("text/html", f))</div>")

# ╔═╡ Cell order:
# ╠═d4aff600-a14a-4c8e-b82e-f0df5c1c6302
# ╠═bef89303-1433-4b91-8ccb-fb61da42cbc7
# ╠═bda3607d-749c-4bc9-aee8-de02cc81bd96
# ╠═09f82874-4bd7-4ab8-aad6-bd33aa607b05
# ╠═3bd1b4b1-f8c8-4720-96b8-55ebb76d155c
# ╠═27e2f8f2-534a-4584-afbd-0e75f07ea046
# ╠═818bc69d-79e0-4d27-9fef-569bc357654f
# ╠═c5b60867-85b2-4c0c-9606-ae3a2d04a7dd
# ╠═b55f864d-74c9-4ae6-8f72-8092469d3483
# ╠═048bde34-6542-4e5a-998e-298248759568
# ╠═f84badfc-b516-45bc-b495-e0e91fb90e77
# ╠═51166cd4-831d-4a1d-9294-220dce71999b
# ╠═7476507e-2e53-446e-9b34-0520c4e6efcf
