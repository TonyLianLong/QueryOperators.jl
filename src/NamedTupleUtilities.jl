module NamedTupleUtilities

"""
    select(a::NamedTuple, v::Val{n})
Select a field `n` from `a` if it is in `a`.
```jldoctest
julia> QueryOperators.NamedTupleUtilities.select((a=1,b=2,c=3),Val(:a))
(a = 1,)
```
"""
@generated function select(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = ((i for i in an if i == bn)...,)
    types = Tuple{(fieldtype(a, n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

"""
    remove(a::NamedTuple, v::Val{n})
Remove a field `n` from the `a` if it is in `a`.
```jldoctest
julia> QueryOperators.NamedTupleUtilities.remove((a=1,b=2,c=3),Val(:c))
(a = 1, b = 2)
```
"""
@generated function remove(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = ((i for i in an if i != bn)...,)
    types = Tuple{(fieldtype(a, n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

"""
    range(a::NamedTuple, b::Val{n}, c::Val{n})
Return a NamedTuple which retains the fields from `b` to `c` in `a`. 
If `b` is not in `a`, then it will return the empty NamedTuple. 
If `c` is not in `a`, then it will return everything starting with `b`.
```jldoctest
julia> QueryOperators.NamedTupleUtilities.range((a=1,b=2,c=3),Val(:a),Val(:b))
(a = 1, b = 2)
```
"""
@generated function range(a::NamedTuple{an}, ::Val{bn}, ::Val{cn}) where {an, bn, cn}
    rangeStarted = false
    names = Symbol[]
    for n in an
        if n == bn
            rangeStarted = true
        end
        if rangeStarted
            push!(names, n)
        end
        if n == cn
            # rangeStarted = false
            break
        end
    end
    types = Tuple{(fieldtype(a, n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :( NamedTuple{$(names...,),$types}(($(vals...),)) )
end

"""
    range(a::NamedTuple, b::Val{n}, c::Val{n})
Return a NamedTuple which retains `b`th to `c`th fields in `a`. 
If `b` is greater than or equal to `c`, then it will return the empty NamedTuple.
```jldoctest
julia> QueryOperators.NamedTupleUtilities.range((a=1,b=2,c=3),1,2)
(a = 1, b = 2)
```
"""
@generated function range(a::NamedTuple{an}, b::Int, c::Int) where {an}
    rangeStarted = false
    names = Symbol[]
    count = 1
    for n in an
        if count == b
            rangeStarted = true
        end
        if rangeStarted
            push!(names, n)
        end
        if count == c
            rangeStarted = false
            break
        end
        count += 1
    end
    types = Tuple{(fieldtype(a, n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :( NamedTuple{$(names...,),$types}(($(vals...),)) )
end

"""
    rename(a::NamedTuple, b::Val{n}, c::Val{n})
Return a NamedTuple derived from `a` in which the the field from `b` is renamed to `c`. 
If `b` is not in `a`, then it will return the original NamedTuple. 
If `c` is in `a`, then `ERROR: duplicate field name in NamedTuple: "c" is not unique` will occur.
```jldoctest
julia> QueryOperators.NamedTupleUtilities.rename((a = 1, b = 2, c = 3),Val(:a),Val(:d))
(d = 1, b = 2, c = 3)
julia> QueryOperators.NamedTupleUtilities.rename((a = 1, b = 2, c = 3),Val(:m),Val(:d))
(a = 1, b = 2, c = 3)
julia> QueryOperators.NamedTupleUtilities.rename((a = 1, b = 2, c = 3),Val(:a),Val(:c))
ERROR: duplicate field name in NamedTuple: "c" is not unique
```
"""
@generated function rename(a::NamedTuple{an}, ::Val{bn}, ::Val{cn}) where {an, bn, cn}
    names = Symbol[]
    typesArray = DataType[]
    vals = Expr[]
    for n in an
        if n == bn
            push!(names, cn)
        else
            push!(names, n)
        end
        push!(typesArray, fieldtype(a, n))
        push!(vals, :(getfield(a, $(QuoteNode(n)))))
    end
    types = Tuple{typesArray...}
    return :(NamedTuple{$(names...,),$types}(($(vals...),)))
end

"""
    startswith(a::NamedTuple, b::Val{n})
Return a NamedTuple which retains the fields with names starting with `b` in `a`. 
```jldoctest
julia> QueryOperators.NamedTupleUtilities.startswith((abc=1,bcd=2,cde=3),Val(:a))
(abc = 1,)
```
"""
@generated function startswith(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = ((i for i in an if Base.startswith(String(i), String(bn)))...,)
    types = Tuple{(fieldtype(a, n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

"""
    startswith(a::NamedTuple, b::Val{n})
Return a NamedTuple which retains the fields with names that do not start with `b` in `a`. 
```jldoctest
julia> QueryOperators.NamedTupleUtilities.not_startswith((abc=1,bcd=2,cde=3),Val(:a))
(bcd = 2, cde = 3)
```
"""
@generated function not_startswith(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = ((i for i in an if !Base.startswith(String(i), String(bn)))...,)
    types = Tuple{(fieldtype(a, n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

"""
    endswith(a::NamedTuple, b::Val{n})
Return a NamedTuple which retains the fields with names ending with `b` in `a`. 
```jldoctest
julia> QueryOperators.NamedTupleUtilities.endswith((abc=1,bcd=2,cde=3),Val(:d))
(bcd = 2,)
```
"""
@generated function endswith(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = ((i for i in an if Base.endswith(String(i), String(bn)))...,)
    types = Tuple{(fieldtype(a, n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

"""
    endswith(a::NamedTuple, b::Val{n})
Return a NamedTuple which retains the fields with names that do not end with `b` in `a`. 
```jldoctest
julia> QueryOperators.NamedTupleUtilities.not_endswith((abc=1,bcd=2,cde=3),Val(:d))
(abc = 1, cde = 3)
```
"""
@generated function not_endswith(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = ((i for i in an if !Base.endswith(String(i), String(bn)))...,)
    types = Tuple{(fieldtype(a, n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

"""
    occursin(a::NamedTuple, b::Val{n})
Return a NamedTuple which retains the fields with names containing `b` as a substring. 
```jldoctest
julia> QueryOperators.NamedTupleUtilities.occursin((abc=1,bcd=2,cde=3),Val(:d))
(bcd = 2, cde = 3)
```
"""
@generated function occursin(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = ((i for i in an if Base.occursin(String(bn), String(i)))...,)
    types = Tuple{(fieldtype(a, n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

"""
    not_occursin(a::NamedTuple, b::Val{n})
Return a NamedTuple which retains the fields without names containing `b` as a substring. 
```jldoctest
julia> QueryOperators.NamedTupleUtilities.not_occursin((abc=1,bcd=2,cde=3),Val(:d))
(abc = 1,)
```
"""
@generated function not_occursin(a::NamedTuple{an}, ::Val{bn}) where {an, bn}
    names = ((i for i in an if !Base.occursin(String(bn), String(i)))...,)
    types = Tuple{(fieldtype(a, n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

"""
    oftype(a::NamedTuple, b::DataType)
Returns a NamedTuple which retains the fields whose elements have type `b`.
```jldoctest
julia> QueryOperators.NamedTupleUtilities.oftype((a = [4,5,6], b = [3.,2.,1.], c = ["He","llo","World!"]), Int64)
(a = [4, 5, 6],)
```
"""
@generated function oftype(a::NamedTuple{an}, b::DataType) where {an}
    names = ((i for i in an if eltype(fieldtype(a, i)) isa b)...,)
    types = Tuple{(fieldtype(a, n) for n in names)...}
    vals = Expr[:(getfield(a, $(QuoteNode(n)))) for n in names]
    return :(NamedTuple{$names,$types}(($(vals...),)))
end

end