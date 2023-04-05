import CSwiftLED

public struct MatrixOptions {
    public init() {}
    
    public var hardware_mapping: String?
    public var rows: Int32 {
        get { underlyingOptions.rows }
        set { underlyingOptions.rows = newValue }
    }
    public var cols: Int32 {
        get { underlyingOptions.cols }
        set { underlyingOptions.cols = newValue }
    }
    public var chain_length: Int32 {
        get { underlyingOptions.chain_length }
        set { underlyingOptions.chain_length = newValue }
    }
    public var parallel: Int32 {
        get { underlyingOptions.parallel }
        set { underlyingOptions.parallel = newValue }
    }
    public var disable_hardware_pulsing: Bool {
        get { underlyingOptions.disable_hardware_pulsing }
        set { underlyingOptions.disable_hardware_pulsing = newValue }
    }
    public var limit_refresh_rate_hz: Int32 {
        get { underlyingOptions.limit_refresh_rate_hz }
        set { underlyingOptions.limit_refresh_rate_hz = newValue }
    }
    
    private var underlyingOptions = RGBLedMatrixOptions()
    
    func withTemporaryOptions(_ block: (UnsafeMutablePointer<RGBLedMatrixOptions>)->Void) {
        var optionsCopy = underlyingOptions
        hardware_mapping?.withCString({ cStr in
            optionsCopy.hardware_mapping = cStr
            block(&optionsCopy)
        })
    }
}

public struct RuntimeOptions {
    public init() {}
    
    public var gpio_slowdown: Int32 {
        get { underlyingOptions.gpio_slowdown }
        set { underlyingOptions.gpio_slowdown = newValue }
    }
    private var underlyingOptions = RGBLedRuntimeOptions()
    func withTemporaryOptions(_ block: (UnsafeMutablePointer<RGBLedRuntimeOptions>)->Void) {
        var optionsCopy = underlyingOptions
        block(&optionsCopy)
    }
}

public class LEDMatrix {
    private var matrixPtr: OpaquePointer?
    public init(options: MatrixOptions, runtimeOptions: RuntimeOptions) {
        options.withTemporaryOptions { matrixOptionsPtr in
            runtimeOptions.withTemporaryOptions { runtimeOptionsPtr in
                matrixPtr = led_matrix_create_from_options_and_rt_options(matrixOptionsPtr, runtimeOptionsPtr)
            }
        }
    }
    
    public func getCanvas() -> LEDCanvas? {
        guard let matrixPtr, let canvasPtr = led_matrix_get_canvas(matrixPtr) else {
            return nil
        }
        return LEDCanvas(canvasPtr: canvasPtr)
    }
    
    public func createOffscreenCanvas() -> LEDCanvas? {
        guard let matrixPtr, let canvasPtr = led_matrix_create_offscreen_canvas(matrixPtr) else {
            return nil
        }
        return LEDCanvas(canvasPtr: canvasPtr)
    }
    
    @discardableResult
    public func swapCanvasOnVSync(_ canvas: LEDCanvas) -> LEDCanvas? {
        guard let matrixPtr, let canvasPtr = led_matrix_swap_on_vsync(matrixPtr, canvas.canvasPtr) else {
            return nil
        }
        return LEDCanvas(canvasPtr: canvasPtr)
    }
    
    deinit {
        if let matrixPtr {
            led_matrix_delete(matrixPtr)
        }
        matrixPtr = nil
    }
}

public class LEDCanvas {
    // note: canvas pointers are owned by a matrix so we are not responsible for freeing them
    internal let canvasPtr: OpaquePointer
    public let size: Size
    
    init(canvasPtr: OpaquePointer) {
        self.canvasPtr = canvasPtr
        
        var width: Int32 = 0
        var height: Int32 = 0
        led_canvas_get_size(canvasPtr, &width, &height)
        size = Size(width: Int(width), height: Int(height))
    }
    
    public func clear() {
        led_canvas_clear(canvasPtr)
    }
    
    public func fill(with color: Color) {
        led_canvas_fill(canvasPtr, color.r, color.g, color.b)
    }
    
    public func setPixel(_ pixel: Pixel, color: Color) {
        led_canvas_set_pixel(canvasPtr, pixel.x, pixel.y, color.r, color.g, color.b)
    }
}

