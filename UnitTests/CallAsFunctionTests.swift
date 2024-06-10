//  Created by Jonathan Lehr on 6/4/24.
//

import XCTest

struct Message {
    
    func callAsFunction(name: String, text: String) {
        print("Message from \(name): \(text)")
    }
}

final class CallAsFunctionTests: XCTestCase {
    
    func testSendingMessage() {
        let message = Message()
        message(name: "Fred", text: "Hello there!")
    }
}
