const std = @import("std");
const gl = @cImport({
    // Disables GLFW's inclusion of GL libraries
    @cDefine("GLFW_INCLUDE_NONE", {});
    @cInclude("GLFW/glfw3.h");
    @cInclude("glad/glad.h");
});
const render = @import("rendering/render.zig");
const board = @import("board.zig");

pub fn main() !void {
    const window = try render.windowInit();
    defer render.windowDeinit(window);

    const game_board = board.boardFromFen(board.start_fen).?;
    const render_state = try render.RenderState.init();

    while (render.windowIsRunning(window)) {
        render_state.updatePiecePositions(game_board);
        render_state.render();

        gl.glfwSwapBuffers(window);
        gl.glfwPollEvents();
    }
}
