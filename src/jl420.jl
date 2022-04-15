module jl420

using HypertextLiteral
using Base64

function data_url(f)
    io = IOBuffer();
    write(io,"data:image/png;base64,")
    iob64 = Base64EncodePipe(io)
    show(iob64, "image/png", f)
    String(take!(io))
end


for n in names(@__MODULE__; all=true)
    if Base.isidentifier(n) && n ∉ (Symbol(@__MODULE__), :eval, :include)
        @eval export $n
    end
end

end # module
