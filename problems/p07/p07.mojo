from memory import UnsafePointer
from gpu import thread_idx, block_idx, block_dim
from gpu.host import DeviceContext
from testing import assert_equal

# ANCHOR: add_10_blocks_2d
alias SIZE = 5
alias BLOCKS_PER_GRID = (2, 2)
alias THREADS_PER_BLOCK = (3, 3)
alias dtype = DType.float32


fn add_10_blocks_2d(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    size: Int,
):
<<<<<<< HEAD
    row = block_dim.y * block_idx.y + thread_idx.y
    col = block_dim.x * block_idx.x + thread_idx.x
    # FILL ME IN (roughly 2 lines)
=======
    global_i = block_dim.x * block_idx.x + thread_idx.x
    global_j = block_dim.y * block_idx.y + thread_idx.y
    if global_i < size and global_j < size:
        out[global_i * size + global_j] = a[global_i * size + global_j] + 10
>>>>>>> 486345c (p01-p07 solutions)


# ANCHOR_END: add_10_blocks_2d


def main():
    with DeviceContext() as ctx:
        out = ctx.enqueue_create_buffer[dtype](SIZE * SIZE).enqueue_fill(0)
        expected = ctx.enqueue_create_host_buffer[dtype](
            SIZE * SIZE
        ).enqueue_fill(1)
        a = ctx.enqueue_create_buffer[dtype](SIZE * SIZE).enqueue_fill(1)
        ctx.enqueue_function[add_10_blocks_2d](
            out.unsafe_ptr(),
            a.unsafe_ptr(),
            SIZE,
            grid_dim=BLOCKS_PER_GRID,
            block_dim=THREADS_PER_BLOCK,
        )

        ctx.synchronize()

        for i in range(SIZE):
            for j in range(SIZE):
                expected[i * SIZE + j] += 10

        with out.map_to_host() as out_host:
            print("out:", out_host)
            print("expected:", expected)
            for i in range(SIZE):
                for j in range(SIZE):
                    assert_equal(out_host[i * SIZE + j], expected[i * SIZE + j])
