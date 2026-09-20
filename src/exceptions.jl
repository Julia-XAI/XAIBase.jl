struct NotImplementedError <: Exception
    analyzer::AbstractXAIMethod
    method::String
end

function Base.showerror(io::IO, e::NotImplementedError)
    T = string(typeof(e.analyzer))
    printstyled(io, "NotImplementedError: "; color = :red)
    println(io, "The `$T` analyzer doesn't fully implement the XAIBase interface.")
    return print(io, "Please implement `", e.method, "` for your type `T<:$T`.")
end

struct InterfaceError <: Exception
    analyzer::AbstractXAIMethod
    msg::String
end

function Base.showerror(io::IO, e::InterfaceError)
    T = string(typeof(e.analyzer))
    printstyled(io, "InterfaceError: "; color = :red)
    println(io, "The `$T` analyzer violates the XAIBase interface.")
    return print(io, e.msg)
end
