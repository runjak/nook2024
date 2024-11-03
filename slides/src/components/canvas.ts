const makeShader = (
  gl: WebGLRenderingContext,
  src: string,
  type: WebGLRenderingContext["VERTEX_SHADER" | "FRAGMENT_SHADER"]
): WebGLShader => {
  const shader = gl.createShader(type);

  if (!shader) {
    throw new Error("Could not create shader");
  }

  gl.shaderSource(shader, src);
  gl.compileShader(shader);

  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    throw new Error("Error compiling shader: " + gl.getShaderInfoLog(shader));
  }

  return shader;
};

const initShaders = (
  gl: WebGLRenderingContext,
  vs_source: string,
  fs_source: string
): WebGLProgram => {
  const vertexShader = makeShader(gl, vs_source, gl.VERTEX_SHADER);
  const fragmentShader = makeShader(gl, fs_source, gl.FRAGMENT_SHADER);

  const glProgram = gl.createProgram();
  if (!glProgram) {
    throw new Error("Failed to create program");
  }

  gl.attachShader(glProgram, vertexShader);
  gl.attachShader(glProgram, fragmentShader);

  gl.linkProgram(glProgram);
  if (!gl.getProgramParameter(glProgram, gl.LINK_STATUS)) {
    throw new Error("Unable to initialize the shader program");
  }

  gl.useProgram(glProgram);

  return glProgram;
};

const initVertexBuffers = (
  gl: WebGLRenderingContext,
  program: WebGLProgram
): number => {
  const dim = 2;
  const vertices = new Float32Array(
    [
      // Triangle 1
      [
        [-1, 1],
        [1, 1],
        [1, -1],
      ].flat(),
      // Triangle 2
      [
        [-1, 1],
        [1, -1],
        [-1, -1],
      ].flat(),
    ].flat()
  );

  // Create a buffer object
  const vertexBuffer = gl.createBuffer();
  if (!vertexBuffer) {
    throw new Error("Failed to create the buffer object");
  }

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
  gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

  // Assign the vertices in buffer object to a_Position variable
  const a_Position = gl.getAttribLocation(program, "a_Position");
  if (a_Position < 0) {
    throw new Error("Failed to get the storage location of a_Position");
  }
  gl.vertexAttribPointer(a_Position, dim, gl.FLOAT, false, 0, 0);
  gl.enableVertexAttribArray(a_Position);

  // Return number of vertices
  return vertices.length / dim;
};

const initUniforms = (
  gl: WebGLRenderingContext,
  program: WebGLProgram,
  canvas: HTMLCanvasElement,
  draw: VoidFunction
) => {
  // https://en.wikibooks.org/wiki/Fractals/shadertoy#uniforms
  const iResolution = gl.getUniformLocation(program, "iResolution");
  if (iResolution) {
    gl.uniform3fv(iResolution, [
      canvas.width,
      canvas.height,
      canvas.width / canvas.height,
    ]);
  }

  const iGlobalTime = gl.getUniformLocation(program, "iGlobalTime");
  if (iGlobalTime) {
    const step = (time: DOMHighResTimeStamp) => {
      gl.uniform1f(iGlobalTime, time / 1_000);

      draw();

      window.requestAnimationFrame(step);
    };

    window.requestAnimationFrame(step);
  }

  /**
   * Different than Shadertoy
   * https://www.shadertoy.com/view/Mss3zH
   * https://gist.github.com/markknol/d06c0167c75ab5c6720fe9083e4319e1
   */
  const iMouse = gl.getUniformLocation(program, "iMouse");
  if (iMouse) {
    // canvas specific click state
    let [clickX, clickY] = [0, 0];

    canvas.addEventListener("mousemove", (event) => {
      const { clientX: x, clientY: y } = event;

      gl.uniform4fv(iMouse, [x, y, clickX, clickY]);
    });

    canvas.addEventListener("click", (event) => {
      const { clientX: x, clientY: y } = event;

      gl.uniform4fv(iMouse, [x, y, x, y]);
      [clickX, clickY] = [x, y];
    });
  }
};

const rescaleCanvas = (canvas: HTMLCanvasElement, scale: number) => {
  canvas.width *= scale;
  canvas.height *= scale;
};

export const init = () => {
  const vs = `
      attribute vec4 a_Position;

      void main() {
          gl_Position = a_Position;
      }
      `;

  document.querySelectorAll("canvas").forEach((canvas: HTMLCanvasElement) => {
    rescaleCanvas(canvas, 4);

    const gl = canvas.getContext("webgl");
    if (!gl) {
      console.error(
        "Failed to get webgl rendering context from canvas",
        canvas
      );
      return;
    }

    const fs = canvas.textContent;
    if (!fs) {
      console.error("Failed to get FragmentShader code for experiment", canvas);
      return;
    }

    const program = initShaders(gl, vs, fs);

    // Write the positions of vertices to a vertex shader
    const n = initVertexBuffers(gl, program);
    if (n < 0) {
      throw new Error("Failed to set the positions of the vertices");
    }

    gl.clearColor(0.0, 0.0, 0.0, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    const draw = () => {
      gl.drawArrays(gl.TRIANGLES, 0, n);
    };

    initUniforms(gl, program, canvas, draw);

    draw();
  });
};
