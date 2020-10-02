import UIKit

// MARK: - Models & Types
typealias DeckStandard = [Int : PlayingCard]

struct PlayingCard: Hashable {
    let value: Int
    let rank: String
    let suit: Character
    let isFace: Bool
    let uniqueIndex: Int
    var report: String { rank + String(suit) }
}

// [[Int]] players hands, [Int] players (for maintaining consistency in players through indexing fo hands through here

struct GameState {
    let players: Int
    let deck: DeckStandard
    // let cardStandard: CardStandard // enum type declaration for type of card
    
    var activePlayer: Int
    var stock: [Int]
    var hands: [[Int]]
    var discardPile: [Int]
    var revealedCards: [Int]
    
    var cardsNotInStock: Set<Int> {
        var piles: Set<Int> = []
        var i = 0
        while i < players {
            piles.formUnion(Set(hands[i]))
            i += 1
        }
        piles.formUnion(Set(discardPile))
        return piles
    }
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
    
    func randomize(withoutIDs ids: Set<Int> = []) -> [Int] {
        var newStock: [Int] = []
        var setOfChosenNumbers: Set<Int> = ids
        var nonce = Int.random(in: 0...51)
        
        while newStock.count < 52 {
            if !setOfChosenNumbers.contains(nonce) {
                setOfChosenNumbers.insert(nonce)
                newStock.append(nonce)
                nonce = Int.random(in: 0...51)
            } else {
                nonce += Int.random(in: 0...25)
                if nonce > 51 { nonce -= 52 }
            }
        }
        
        return newStock
    }
    
    ///Cards are dealt from the 'bottom' of the stack with .popLast()
    func deal(handOf handSize: Int, fromStock stock: inout [Int]) -> [Int] {
        var newHand: [Int] = []
        while newHand.count < (handSize) {
            if let dealtCard = stock.popLast() {
                newHand.append(dealtCard)
            }
        }
        return newHand
    }
    
    ///For disagnostic purposes only
    func draw(cardWithID id: Int, intoHand hand: inout [Int], fromStock stock: inout [Int]) {
        
    }
    
    // TODO: Handle Error case for drawing from an empty stock
    func draw(thisManyCards number: Int, toHand hand: inout [Int], fromPile pile: inout [Int]) {
        guard let dealtCard = pile.popLast() else { return }
        hand.append(dealtCard)
    }
    
    func discard(cardWithLocalID index: Int, fromHand hand: inout [Int], toDiscardPile discardPile: inout [Int]) {
        let uniqueID = hand[index] // reminder: cards are tracked by unique ID and hashed into the Deck for readable values
        hand.remove(at: index)
        discardPile.append(uniqueID)
    }
    
    // Disgnostics
    func displayAsReport(cardID id: Int, inDeck deck: DeckStandard) -> String {
        guard var card = deck[id] else { return "Error" }
        let report = card.report
        return report
    }
    
    func report(fromPile pile: [Int], hashedToDeck deck: DeckStandard) -> [String] {
        var hashedPile: [String] = []
        for i in 0..<pile.count {
            hashedPile.append(displayAsReport(cardID: pile[i], inDeck: deck))
        }
        return hashedPile
    }
    
    func report(fromPiles piles: [[Int]], hashedToDeck deck: DeckStandard) -> [[String]] {
        var hashedPiles: [[String]] = []
        while hashedPiles.count < piles.count {
            hashedPiles.append(report(fromPile: piles[hashedPiles.count], hashedToDeck: deck))
        }
        return hashedPiles
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
        var handsConfigured = [[Int()]]
        let dealtHand = DeckBuilder().deal(handOf: 5, fromStock: &shuffledStock)
        handsConfigured[0] = dealtHand
        gameState = GameState(players: players, deck: standardDeck, activePlayer: 0, stock: shuffledStock, hands: handsConfigured, discardPile: [Int](), revealedCards: [Int]())
        guard var gameState = gameState else { return }
        printAllZones(ofGameState: gameState)
//        DeckBuilder().report(fromPile: gameState.hand, hashedToDeck: gameState.deck)
    }
    func dealHand(ofNumber cards: Int, fromStock stock: inout [Int]) -> [Int] {
        return DeckBuilder().deal(handOf: 5, fromStock: &stock)
        
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
    
    func printHand(ofPlayer player: Int, ofGameState gameState: GameState) {
        Swift.print("Hand:")
        Swift.print(gameState.hands[player])
    }
    
    func printStock(ofGameState gameState: GameState) {
        Swift.print("Stock:")
        Swift.print(gameState.stock)
    }
    
    func printDiscardPile(ofGameState gameState: GameState) {
        Swift.print("DiscardPile:")
        Swift.print(gameState.discardPile)
    }
    
    func printAllZones(ofGameState gameState: GameState) {
        print("Hand:")
        print(DeckBuilder().report(fromPile: gameState.hands[0], hashedToDeck: gameState.deck))
        print("DiscardPile:")
        print(DeckBuilder().report(fromPile: gameState.discardPile, hashedToDeck: gameState.deck))
        print("Stock:")
        print(DeckBuilder().report(fromPile: gameState.stock, hashedToDeck: gameState.deck))
//        printHand(ofGameState: gameState)
//        printStock(ofGameState: gameState)
//        printDiscardPile(ofGameState: gameState)
    }
    
    func checkDeckIntegrity(ofGameState gameState: GameState) -> Bool {
        var checkDeck: Set<Int> = []
        for i in 0...51 {
            checkDeck.update(with: i)
        }
        // TODO: Handling multiple players' hands
        for i in 0..<gameState.players {
            for j in 0..<gameState.hands[i].count {
                checkDeck.remove(gameState.hands[i][j])
            }
        }
        for i in 0..<gameState.stock.count {
            checkDeck.remove(gameState.stock[i])
        }
        for i in 0..<gameState.discardPile.count {
            checkDeck.remove(gameState.discardPile[i])
        }
        return checkDeck.isEmpty
    }
    
    // Instances
    
    func instance1() {
        let deckBuilder = DeckBuilder()
        guard var gameState = gameState else { return }
        var hand = deckBuilder.deal(handOf: 5, fromStock: &gameState.stock)
        gameState.hands[0] = hand
        deckBuilder.report(fromPile: gameState.hands[0], hashedToDeck: gameState.deck)
        printHand(ofPlayer: 0, ofGameState: gameState)
        deckBuilder.draw(thisManyCards: 1, toHand: &gameState.hands[0], fromPile: &gameState.stock)
        printHand(ofPlayer: 0, ofGameState: gameState)
        deckBuilder.draw(thisManyCards: 2, toHand: &gameState.hands[0], fromPile: &gameState.stock)
        printHand(ofPlayer: 0, ofGameState: gameState)
        deckBuilder.discard(cardWithLocalID: 0, fromHand: &gameState.hands[0], toDiscardPile: &gameState.discardPile)
        printHand(ofPlayer: 0, ofGameState: gameState)
        printDiscardPile(ofGameState: gameState)
        printStock(ofGameState: gameState)
        printAllZones(ofGameState: gameState)
    }
    
    // Zones
    
    var gameState: GameState?
}


//let gameEnvironment = GameEnvironment()
//gameEnvironment.setup(numberOfPlayers: 1)
//gameEnvironment.instance1()

class GameHandlerForDraw5Poker {
    
    init() {
        setup(numberOfPlayers: 2)
    }
    var gameState: GameState?
    // initialize gameState
    func setup(numberOfPlayers players: Int) {
        let standardDeck = DeckBuilder().constructDeck()
        var shuffledStock = DeckBuilder().randomize()
        var handsConfigured = Array(repeating: Array(repeating: 0, count: 5), count: players)
//        let dealtHand = [0, 1, 2, 3, 4]
//        handsConfigured[0] = dealtHand
        gameState = GameState(players: players, deck: standardDeck, activePlayer: 0, stock: shuffledStock, hands: handsConfigured, discardPile: [Int](), revealedCards: [Int]())
    //        DeckBuilder().report(fromPile: gameState.hand, hashedToDeck: gameState.deck)
        dealHands(thisManyCards: 5)
//        print(DeckBuilder().report(fromPile: gameState!.hands[0], hashedToDeck: gameState!.deck))
    }
    
    func testGameFlow() {
//        exchange(cards: <#T##Int#>, withIDs: <#T##[Int]#>, inGameState: &<#T##GameState#>)
    }
    
    func dealHands(thisManyCards cards: Int) {
        var i = 0
        guard var gs = gameState else { return }
        while i < gs.players {
            let dealtHand = DeckBuilder().deal(handOf: cards, fromStock: &gs.stock)
            gs.hands[i] = dealtHand
            i += 1
        }
        print(DeckBuilder().report(fromPiles: gs.hands, hashedToDeck: gs.deck))
//        print(DeckBuilder().report(fromPile: gs.hands[1], hashedToDeck: gs.deck))
    }
    // turn structure (including changing active player)
    func advanceTurn(ofGameState gameState: inout GameState) {
        let nextPlayerIndex = gameState.activePlayer + 1
        gameState.activePlayer = (nextPlayerIndex >= gameState.players ? nextPlayerIndex :  0)
        // draw cards
    }
    func exchange(cards: Int, withIDs ids: [Int], inGameState gs: inout GameState) {
        let ap = gs.activePlayer
        var apHand = gs.hands[ap]
        for id in ids {
            DeckBuilder().discard(cardWithLocalID: id, fromHand: &apHand, toDiscardPile: &gs.discardPile)
        }
        DeckBuilder().draw(thisManyCards: cards, toHand: &apHand, fromPile: &gs.stock)
        advanceTurn(ofGameState: &gs)
    }
}

let gh = GameHandlerForDraw5Poker()

func isFlush(hand: [Int], fromDeck deck: DeckStandard) -> Bool {
    let heldSuit = deck[hand[0]]!.suit
    for id in hand {
        if deck[id]!.suit != heldSuit {
            return false
        }
    }
    return true
}

func score(hand: [Int]) -> Int {
    
    let deck = DeckBuilder().constructDeck()
    
    var score = 0
    // aliases for scores
    
    let flushStatus = isFlush(hand: hand, fromDeck: deck)
    
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

func tenderCard(fromID id: Int, inDeck deck: DeckStandard) -> PlayingCard {
    return deck[id]!
}

func isStraight(handIDs hand: [Int], fromDeck deck: DeckStandard) -> Bool {
    // assume the hand has been vetted for doubles and there aren't any
    var rankedHand: [PlayingCard] = []
    for id in hand {
        let card = tenderCard(fromID: id, inDeck: deck)
        rankedHand.append(card)
    }
    rankedHand.sort(by: { $0.value < $1.value })
    
    if rankedHand[0].value == 1 && rankedHand[1].value == 10 {
        return true
    } else if rankedHand[4].value > rankedHand[0].value + 4 {
        return false
    }
    return true
}

var stock = DeckBuilder().randomize()
let hand1 = DeckBuilder().deal(handOf: 5, fromStock: &stock)
let hand2 = DeckBuilder().deal(handOf: 5, fromStock: &stock)
