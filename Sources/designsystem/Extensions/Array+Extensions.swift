import Foundation

public extension Array {

    /// Resizes the array to the specified size by either truncating or appending elements.
    /// source: https://stackoverflow.com/a/42822125/254695
    ///
    /// - Parameters:
    ///   - size: The target size of the array.
    ///   - filler: The element to use when expanding the array.
    mutating func resize(to size: Int, with filler: Element) {
        let sizeDifference = size - count
        guard sizeDifference != 0 else {
            return
        }
        if sizeDifference > 0 {
            append(contentsOf: [Element](repeating: filler, count: sizeDifference))
        } else {
            removeLast(sizeDifference * -1) // *-1 because sizeDifference is negative
        }
    }

    /// Returns a resized copy of the array, either truncating or appending elements.
    ///
    /// - Parameters:
    ///   - size: The target size of the new array.
    ///   - filler: The element to use when expanding the array.
    /// - Returns: A new array with the specified size.
    func resized(to size: Int, with filler: Element) -> Array {
        var selfCopy = self
        selfCopy.resize(to: size, with: filler)
        return selfCopy
    }
}
