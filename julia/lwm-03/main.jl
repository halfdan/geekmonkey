using URIParser

struct PNGChunk
    length::UInt32
    type::Vector{UInt8}
    data::Vector{UInt8}
    crc::Vector{UInt8}
end

length(c::PNGChunk) = c.length
type(c::PNGChunk) = String([Char(d) for d in c.type])
function datastr(c::PNGChunk)
    if type(c) == "IHDR"
        height = hton(reinterpret(UInt32, c.data[1:4])[1])
        width = hton(reinterpret(UInt32, c.data[5:8])[1])
        depth = c.data[9]
        ct, cm, fm, im = c.data[10:13]
        return "h=$height, w=$width, d=$depth, color type=$ct, compression method=$cm, filter method=$fm, interlace method=$im"
    elseif type(c) == "tEXt"
        key, value = split(String(Char.(c.data)), '\0')
        value = unescape(value)
        return "$key, $value"
    end
    ""
end

function Base.show(io::IO, c::PNGChunk)
    println(io, length(c), "\t", type(c) ,"\t", datastr(c))
end

const PNG_HEADER = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]

function load_png_chunks(filename)
    io = open(filename, "r") 
    header = Vector{UInt8}(undef, 8)
    readbytes!(io, header)
    if header ≠ PNG_HEADER
        throw(ArgumentError("File is not a PNG"))
    end

    chunks = Vector{PNGChunk}()

    while !eof(io)
        length = hton(read(io, UInt32))

        type = Vector{UInt8}(undef, 4)
        readbytes!(io, type)

        data = Vector{UInt8}(undef, length)
        readbytes!(io, data)

        crc = Vector{UInt8}(undef, 4)
        readbytes!(io, crc)

        push!(chunks, PNGChunk(length, type, data, crc))
    end
    
    close(io)
    chunks
end


chunks = load_png_chunks("Diagram.png")
for chunk ∈ chunks
    print(chunk)
end
