struct NotImplementedError <: Exception
    analyzer::AbstractXAIMethod
    method::String
end

function Base.showerror(io::IO, e::NotImplementedError)
    T = string(typeof(e.analyzer))
    printstyled(io, "NotImplementedError: "; color=:red)
    println(io, "The `$T` analyzer doesn't fully implement the XAIBase interface.")
    print(io, "Please implement `", e.method, "` for your type `T<:$T`.")
end
