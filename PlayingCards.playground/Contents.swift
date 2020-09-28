import UIKit

// MARK: - Models & Types
typealias DeckStandard = [Int : PlayingCard]

struct PlayingCard: Hashable {
    let value: Int
    let rank: String
    let suit: Character
    let isFace: Bool
    let uniqueIndex: Int
}

struct GameState {
    let players: Int
    let deck: DeckStandard
    // let cardStandard: CardStandard // enum type declaration for type of card
    
    var stock: [Int]
    var hand: [Int]
    var discardPile: [Int]
    var revealedCards: [Int]
}


///For distinguishing between types of evaluation or initial values; "tarot" currently deprecated
enum DeckType: String {
    case conventional, tarot
}

// MARK: - Model Controllers

class DeckBuilder {
    func constructDeck() -> DeckStandard {
        var deckAccumulator = DeckStandard()
        
        var suitTicker: Int = 0
        var valueTicker: Int = 1
        var uniqueIndexTicker: Int = 0
        
        while uniqueIndexTicker < 52 {
            var suitActual: Character
            switch suitTicker {
            case 0:
                suitActual = "S"
            case 1:
                suitActual = "H"
            case 2:
                suitActual = "C"
            case 3:
                suitActual = "D"
            default:
                suitActual = "Z"
            }
            
            let faceActual: Bool = (valueTicker > 10 ? true : false)
            
            var rankActual: String
            switch valueTicker {
            case 1:
                rankActual = "A"
            case 11:
                rankActual = "J"
            case 12:
                rankActual = "Q"
            case 13:
                rankActual = "K"
                suitTicker += 1
            default:
                rankActual = String(valueTicker)
            }
            
            let playingCard = PlayingCard(value: valueTicker, rank: rankActual, suit: suitActual, isFace: faceActual, uniqueIndex: uniqueIndexTicker)
            deckAccumulator[uniqueIndexTicker] = playingCard
            
            valueTicker += 1
            if valueTicker > 13 { valueTicker = 1 }
            uniqueIndexTicker += 1
        }
        
        return deckAccumulator
    }
    
    func randomize() -> [Int] {
        var newStock: [Int] = []
        var setOfChosenNumbers: Set<Int> = []
        var nonce = Int.random(in: 0...51)
        
        while newStock.count < 52 {
            if !setOfChosenNumbers.contains(nonce) {
                setOfChosenNumbers.insert(nonce)
                newStock.append(nonce)
                nonce = Int.random(in: 0...51)
            } else {
                nonce += 1
                if nonce > 51 { nonce = 0 }
            }
        }
        
        return newStock
    }
    
    ///Cards are dealt from the 'bottom' of the stack with .popLast()
    func deal(handOf handSize: Int, fromStock stock: inout [Int]) -> [Int] {
        var newHand: [Int] = []
        while newHand.count < (handSize - 1) {
            if let dealtCard = stock.popLast() {
                newHand.append(dealtCard)
            }
        }
        return newHand
    }
    
    // TODO: Handle Error case for drawing from an empty stock
    func draw(thisManyCards number: Int, toHand hand: inout [Int], fromStock stock: inout [Int]) {
        guard let dealtCard = stock.popLast() else { return }
        hand.append(dealtCard)
    }
    
    func discard(cardWithLocalID index: Int, fromHand hand: inout [Int], toDiscardPile discardPile: inout [Int]) {
        let uniqueID = hand[index] // reminder: cards are tracked by unique ID and hashed into the Deck for readable values
        hand.remove(at: index)
        discardPile.append(uniqueID)
    }
}

// MARK: - Testing

//func printDeckDiagnostic(stock: Stock) {
//    for card in stock.stock {
//        print("\(card.rank)\(card.suit) \(card.isFace) \(card.value) id:\(card.uniqueIndex)")
////        print("rank: \(card.rank), value: \(card.value), isFace: \(card.isFace), \n suit: \(card.suit), uniqueID: \(card.uniqueIndex)")
//    }
//}


// Deprecated Shuffling Experiments

//class Luck {
//    init(withSeed seed: Int) {
//        self.seed = seed
//        varianceMax = (seed / 13)
//        if varianceMax < 2 { varianceMax += 2 }
//        seasoning = Int.random(in: 0...varianceMax)
//    }
//
//    let seed: Int
//    var varianceMax: Int
//    var seasoning: Int
//
//    func season() {
//        seasoning = Int.random(in: 0...varianceMax)
//        print(self.seasoning)
//    }
//}


//func shuffle(stock: Stock) {
//    let luck = Luck(withSeed: stock.stock.count)
//    let half = stock.stock.count / 2
//    var tempStock: [PlayingCard]
//
//
//    //separate stock into two roughly equal piles
//    let halfACount = half + luck.seasoning
//    var halfBCount = half - luck.seasoning
//    while halfACount + halfBCount != stock.stock.count {
//        halfBCount += 1
//    }
//
//    tempStock = stock.stock
//    tempStock.removeSubrange(0...halfACount)
//    var pileA: [PlayingCard] = tempStock
//    print(pileA.count)
//
//    tempStock = stock.stock
//    let count = halfACount + 1
//    tempStock.removeSubrange(count..<tempStock.count)
//    var pileB: [PlayingCard] = tempStock
//    print(pileB.count)
//
////    print(pileA.first)
////    print(pileB.first)
//
//    // pop off of each pile in turn a random small number of cards and place them in the new stock
//    var newPile: [PlayingCard] = []
//
//    while pileA.count + pileB.count > 0 {
//        for _ in 0..<luck.seasoning {
//            if let card = pileA.popLast() {
//                newPile.insert(card, at: 0)
//                luck.season()
//            }
//        }
//        for _ in 0..<luck.seasoning {
//            if let card = pileB.popLast() {
//                newPile.insert(card, at: 0)
//                luck.season()
//            }
//        }
//    }
//
//    print(newPile.count)
//    print(newPile.first)
//    // return? the new stock
//}


/*
 
 Game Environment Controller
 deck (type, dictionary of cards indexed by ID number)
 stock
 player's hand (set of card IDs in this zone)
 discard pile (set of card IDs in this zone)
 play area (set of card IDs in this zone)
 
 functions:
 shuffle stock (excludes card IDs in hand and discard)
 draw card (takes top card from deck and adds it to player's hand and tracks ID)
 play card to play area (tracks ID movement)
 
 game checker: did playing a card cause a state change (a win, score, other event?)
 
 */

// MARK: -  Game Zones



class GameEnvironment {
    
    func setup(numberOfPlayers players: Int) {
        let standardDeck = DeckBuilder().constructDeck()
        var shuffledStock = DeckBuilder().randomize()
        let dealtHand = DeckBuilder().deal(handOf: 5, fromStock: &shuffledStock)
        gameState = GameState(players: players, deck: standardDeck, stock: shuffledStock, hand: dealtHand, discardPile: [Int](), revealedCards: [Int]())
    }
    
    // game loop
    
    // function evaluates hand and returns a score (score tracking comes later)
    func score(hand: [Int]) -> Int {
        
        var score = 0
        // aliases for scores
        
        for id in hand {
            // check royal flush dictionaries
            // check for flush (if any do not match the first card, fall through)
            // check array for ranks adjacent; if none present, fall through
            // separate check left and check right algorithms; run one at a time and if the ticker reaches five, it's a straight
            // keep the ticker and run the other one
            // if it doesn't reach five but has run five times, fall throuvh
            // run check for pairs+ first before straights (disqualifies runs) ... under current rules, cardIDs are 13 apart for same rank, and could be checked this way. however, could still find deck[cardID].rank super fast
            
        }
        
        return score
    }
    // ideas:
    // can hard-code some pairings (esp royal flush)
    // can check value order for straight
    // can check ranks for flush
    // ad hoc check for pairs, three-of-a-kind, four-of-a-kind, full house
    // points equal to chance from a 52 card deck (lower is better)
    
    // MARK: - Check GameState values
    
    func printHand(ofGameState gameState: GameState) {
        Swift.print(gameState.hand)
    }
    
    func printStock(ofGameState gameState: GameState) {
        Swift.print(gameState.stock)
    }
    
    func printDiscardPile(ofGameState gameState: GameState) {
        Swift.print(gameState.discardPile)
    }
    
    func printAllZones(ofGameState gameState: GameState) {
        printHand(ofGameState: gameState)
        printStock(ofGameState: gameState)
        printDiscardPile(ofGameState: gameState)
    }
    
    func checkDeckIntegrity(ofGameState gameState: GameState) -> Bool {
        var checkDeck: Set<Int> = []
        for i in 0...51 {
            checkDeck.update(with: i)
        }
        // TODO: Handling multiple players' hands
        for i in 0..<gameState.hand.count {
            checkDeck.remove(gameState.hand[i])
        }
        for i in 0..<gameState.stock.count {
            checkDeck.remove(gameState.stock[i])
        }
        for i in 0..<gameState.discardPile.count {
            checkDeck.remove(gameState.discardPile[i])
        }
        return checkDeck.isEmpty
    }
    
    // Zones
    
    var gameState: GameState?
}
