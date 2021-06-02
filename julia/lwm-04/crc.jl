
function maketable()
    crc_table = Vector{UInt32}(undef, 256)

    for n ∈ 0:255
        c = convert(UInt32, n)
        for _ ∈ 1:8
           if c & 1 == 1
               c = 0xEDB88320 ⊻ (c >> 1)
           else
               c = c >> 1
           end
        end
        crc_table[n+1] = c
    end
    crc_table
end

const crc_table = maketable()

function crc32(data::Vector{UInt8}, crc::UInt32)
    c = crc
    for byte ∈ data 
        c = crc_table[((c ⊻ UInt8(byte)) & 0xff) + 1] ⊻ (c >> 8)
    end
    return c
end

crc32(data::AbstractString, crc::UInt32) = crc32(Vector{UInt8}(data), crc)
