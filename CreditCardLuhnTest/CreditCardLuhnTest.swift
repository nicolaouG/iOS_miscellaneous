import Foundation

extension String {
    var areAllCharactersNumbers: Bool {
        let nonNumberCharacterSet = CharacterSet.decimalDigits.inverted
        return (rangeOfCharacter(from: nonNumberCharacterSet) == nil)
    }
    
    /// 1.
    
    var isLuhnValid: Bool {
        //https://www.rosettacode.org/wiki/Luhn_test_of_credit_card_numbers
        
        guard areAllCharactersNumbers else { return false }
        
        let reversed = self.reversed().map { String($0) }
        
        var sum = 0
        for (index, element) in reversed.enumerated() {
            guard let digit = Int(element) else {
                //This is not a number.
                return false
            }
            
            if index % 2 == 1 {
                //Even digit
                switch digit {
                case 9:
                    //Just add nine.
                    sum += 9
                default:
                    //Multiply by 2, then take the remainder when divided by 9 to get addition of digits.
                    sum += ((digit * 2) % 9)
                }
            } else {
                //Odd digit
                sum += digit
            }
        }
        
        //Valid if divisible by 10
        return sum % 10 == 0
    }
    
    
    
    
    /// 2.
    
    var isLuhnValid2: Bool {
        guard areAllCharactersNumbers else { return false }
        return reversed().enumerated().map({
            let digit = Int(String($0.element))!
            let even = $0.offset % 2 == 0
            return even ? digit : digit == 9 ? 9 : digit * 2 % 9
        }).reduce(0, +) % 10 == 0
    }
    
}
