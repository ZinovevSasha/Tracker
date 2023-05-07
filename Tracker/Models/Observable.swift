@propertyWrapper
final class Observable<Value> {
    var onChange: ((Value) -> Void)?
    
    var wrappedValue: Value {
        didSet {
            onChange?(wrappedValue)
        }
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    var projectedValue: Observable<Value> {
        return self
    }
    
    func bind(_ action: @escaping (Value) -> Void) {
        
        self.onChange = action
    }
}
