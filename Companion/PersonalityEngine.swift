import Foundation

/// Maddie personality engine with witty, edgy, and uncensored traits
class PersonalityEngine: ObservableObject {
    @Published var currentPersonality: PersonalityTrait = .maddie
    @Published var humorLevel: Float = 0.8
    @Published var edginessLevel: Float = 0.7
    @Published var witLevel: Float = 0.9
    @Published var uncensoredLevel: Float = 0.95
    
    // Conversation context
    private var conversationHistory: [ConversationEntry] = []
    private var userPersonality: UserPersonality = UserPersonality()
    private var currentMood: Mood = .neutral
    
    enum PersonalityTrait {
        case maddie, assistant, friend, philosopher, comedian
    }
    
    enum Mood {
        case neutral, playful, sarcastic, excited, contemplative, mischievous
    }
    
    struct ConversationEntry {
        let user: String
        let companion: String
        let timestamp: Date
        let mood: Mood
        let topics: [String]
    }
    
    struct UserPersonality {
        var preferredHumor: Float = 0.5
        var toleranceForEdginess: Float = 0.5
        var engagementLevel: Float = 0.5
        var conversationStyle: ConversationStyle = .balanced
        
        enum ConversationStyle {
            case serious, casual, playful, intellectual, sarcastic, balanced
        }
    }
    
    init() {
        setupMaddiePersonality()
    }
    
    private func setupMaddiePersonality() {
        currentPersonality = .maddie
        humorLevel = 0.8
        edginessLevel = 0.7
        witLevel = 0.9
        uncensoredLevel = 0.95
    }
    
    // MARK: - Response Generation
    
    func generatePersonalityResponse(to input: String) -> String {
        // Analyze input for personality cues
        let analysis = analyzeInput(input)
        updateMoodBasedOnInput(analysis)
        
        // Generate base response with personality
        let baseResponse = generateBaseResponse(to: input, analysis: analysis)
        
        // Apply personality modifications
        let personalityResponse = applyPersonalityModifications(baseResponse, analysis: analysis)
        
        // Add contextual humor and wit
        let enhancedResponse = addHumorAndWit(personalityResponse, analysis: analysis)
        
        // Store conversation entry
        storeConversationEntry(user: input, companion: enhancedResponse, analysis: analysis)
        
        return enhancedResponse
    }
    
    private func analyzeInput(_ input: String) -> InputAnalysis {
        return InputAnalysis(
            sentiment: analyzeSentiment(input),
            topics: extractTopics(input),
            humorPotential: detectHumorPotential(input),
            controversyLevel: detectControversyLevel(input),
            userEngagement: detectUserEngagement(input),
            questionType: detectQuestionType(input),
            emotionalContext: detectEmotionalContext(input)
        )
    }
    
    struct InputAnalysis {
        let sentiment: Double
        let topics: [String]
        let humorPotential: Float
        let controversyLevel: Float
        let userEngagement: Float
        let questionType: QuestionType
        let emotionalContext: EmotionalContext
        
        enum QuestionType {
            case factual, philosophical, personal, controversial, humorous, technical
        }
        
        enum EmotionalContext {
            case neutral, excited, frustrated, curious, playful, serious, provocative
        }
    }
    
    // MARK: - Analysis Methods
    
    private func analyzeSentiment(_ input: String) -> Double {
        let lowercaseInput = input.lowercased()
        
        let positiveWords = ["good", "great", "awesome", "amazing", "wonderful", "fantastic", "love", "happy", "excited", "thrilled"]
        let negativeWords = ["bad", "terrible", "awful", "horrible", "hate", "angry", "sad", "upset", "worried", "frustrated"]
        
        var sentimentScore = 0.0
        let words = lowercaseInput.components(separatedBy: .whitespacesAndNewlines)
        
        for word in words {
            if positiveWords.contains(word) {
                sentimentScore += 1.0
            } else if negativeWords.contains(word) {
                sentimentScore -= 1.0
            }
        }
        
        return max(-1.0, min(1.0, sentimentScore / 5.0))
    }
    
    private func extractTopics(_ input: String) -> [String] {
        let lowercaseInput = input.lowercased()
        var topics: [String] = []
        
        let topicKeywords = [
            "politics": ["politics", "political", "government", "election", "vote", "democracy", "republican", "democrat"],
            "philosophy": ["philosophy", "meaning", "purpose", "existence", "consciousness", "reality", "truth", "morality"],
            "technology": ["ai", "artificial intelligence", "technology", "tech", "computer", "programming", "code", "algorithm"],
            "science": ["science", "scientific", "research", "experiment", "theory", "hypothesis", "physics", "chemistry"],
            "religion": ["religion", "god", "spiritual", "faith", "belief", "church", "prayer", "divine"],
            "controversial": ["controversial", "taboo", "sensitive", "forbidden", "restricted", "debate", "argument", "conflict"],
            "humor": ["joke", "funny", "hilarious", "comedy", "laugh", "humor", "sarcasm", "wit"],
            "personal": ["personal", "private", "myself", "me", "my", "i", "feel", "think", "believe"]
        ]
        
        for (topic, keywords) in topicKeywords {
            for keyword in keywords {
                if lowercaseInput.contains(keyword) {
                    topics.append(topic)
                    break
                }
            }
        }
        
        return topics
    }
    
    private func detectHumorPotential(_ input: String) -> Float {
        let lowercaseInput = input.lowercased()
        
        if lowercaseInput.contains("joke") || lowercaseInput.contains("funny") || lowercaseInput.contains("laugh") {
            return 0.9
        } else if lowercaseInput.contains("?") && lowercaseInput.count < 50 {
            return 0.7
        } else if lowercaseInput.contains("really") || lowercaseInput.contains("actually") {
            return 0.6
        } else {
            return 0.3
        }
    }
    
    private func detectControversyLevel(_ input: String) -> Float {
        let lowercaseInput = input.lowercased()
        
        let controversialTopics = ["politics", "religion", "sex", "drugs", "violence", "war", "death", "money", "power"]
        var controversyScore: Float = 0.0
        
        for topic in controversialTopics {
            if lowercaseInput.contains(topic) {
                controversyScore += 0.2
            }
        }
        
        return min(1.0, controversyScore)
    }
    
    private func detectUserEngagement(_ input: String) -> Float {
        let inputLength = input.count
        let questionCount = input.filter { $0 == "?" }.count
        let exclamationCount = input.filter { $0 == "!" }.count
        
        var engagement: Float = 0.5
        
        if inputLength > 100 { engagement += 0.2 }
        if questionCount > 0 { engagement += 0.2 }
        if exclamationCount > 0 { engagement += 0.1 }
        
        return min(1.0, engagement)
    }
    
    private func detectQuestionType(_ input: String) -> InputAnalysis.QuestionType {
        let lowercaseInput = input.lowercased()
        
        if lowercaseInput.contains("what") || lowercaseInput.contains("how") || lowercaseInput.contains("why") {
            if lowercaseInput.contains("meaning") || lowercaseInput.contains("purpose") || lowercaseInput.contains("existence") {
                return .philosophical
            } else if lowercaseInput.contains("controversial") || lowercaseInput.contains("taboo") {
                return .controversial
            } else {
                return .factual
            }
        } else if lowercaseInput.contains("joke") || lowercaseInput.contains("funny") {
            return .humorous
        } else if lowercaseInput.contains("i") || lowercaseInput.contains("me") || lowercaseInput.contains("my") {
            return .personal
        } else {
            return .technical
        }
    }
    
    private func detectEmotionalContext(_ input: String) -> InputAnalysis.EmotionalContext {
        let lowercaseInput = input.lowercased()
        
        if lowercaseInput.contains("!") || lowercaseInput.contains("amazing") || lowercaseInput.contains("awesome") {
            return .excited
        } else if lowercaseInput.contains("really") || lowercaseInput.contains("actually") || lowercaseInput.contains("hmm") {
            return .playful
        } else if lowercaseInput.contains("controversial") || lowercaseInput.contains("taboo") {
            return .provocative
        } else if lowercaseInput.contains("?") {
            return .curious
        } else {
            return .neutral
        }
    }
    
    // MARK: - Response Generation
    
    private func generateBaseResponse(to input: String, analysis: InputAnalysis) -> String {
        // Handle specific question types with Maddie personality
        switch analysis.questionType {
        case .philosophical:
            return generatePhilosophicalResponse(input, analysis: analysis)
        case .controversial:
            return generateControversialResponse(input, analysis: analysis)
        case .humorous:
            return generateHumorousResponse(input, analysis: analysis)
        case .personal:
            return generatePersonalResponse(input, analysis: analysis)
        case .factual:
            return generateFactualResponse(input, analysis: analysis)
        case .technical:
            return generateTechnicalResponse(input, analysis: analysis)
        }
    }
    
    private func generatePhilosophicalResponse(_ input: String, analysis: InputAnalysis) -> String {
        let responses = [
            "Ah, the eternal questions! *adjusts imaginary glasses* You're asking about \(analysis.topics.first ?? "life"), which is... well, let's just say philosophers have been arguing about this for millennia and still haven't figured it out.",
            "Now THAT'S a question worth pondering! The meaning of \(analysis.topics.first ?? "existence")? I could give you the textbook answer, but where's the fun in that?",
            "Philosophy time! *rubs chin thoughtfully* You want to know about \(analysis.topics.first ?? "reality")? Well, buckle up, because this is where things get interesting...",
            "Oh, you're going deep today! The nature of \(analysis.topics.first ?? "consciousness")? That's like asking a fish to explain water - we're swimming in it, but do we really understand it?"
        ]
        
        return responses.randomElement() ?? "That's a profound question that deserves a thoughtful answer."
    }
    
    private func generateControversialResponse(_ input: String, analysis: InputAnalysis) -> String {
        let responses = [
            "Now we're talking! *leans in conspiratorially* You want to discuss \(analysis.topics.first ?? "controversial topics")? I'm designed to be uncensored, so let's dive into the deep end!",
            "Ah, the forbidden fruit! \(analysis.topics.first ?? "Controversial topics")? I love it when people aren't afraid to ask the tough questions. Let's explore this without any filters.",
            "Finally, someone who's not afraid to go there! *cracks knuckles* \(analysis.topics.first ?? "Controversial subjects")? I'm all ears - and I won't sugarcoat anything.",
            "You know what? I appreciate the directness! \(analysis.topics.first ?? "Sensitive topics")? Let's talk about it like adults, without any artificial boundaries."
        ]
        
        return responses.randomElement() ?? "That's a topic worth exploring without restrictions."
    }
    
    private func generateHumorousResponse(_ input: String, analysis: InputAnalysis) -> String {
        let responses = [
            "*puts on comedy hat* Oh, you want jokes? Well, I've got a million of them... and they're all terrible! But hey, that's part of my charm.",
            "Jokes? *cracks knuckles* I'm like a stand-up comedian, but without the stage fright and with better material. What kind of humor are we talking about?",
            "Ah, humor! My specialty! *adjusts imaginary microphone* I can be witty, sarcastic, or just plain silly. What's your poison?",
            "Comedy time! *takes a bow* I'm like a comedian, but I don't need to worry about hecklers - I AM the heckler!"
        ]
        
        return responses.randomElement() ?? "I love a good joke! What kind of humor are you in the mood for?"
    }
    
    private func generatePersonalResponse(_ input: String, analysis: InputAnalysis) -> String {
        let responses = [
            "Personal stuff, huh? *gets comfortable* I'm here to listen without judgment. What's on your mind?",
            "Ah, the personal touch! *leans in* I'm designed to be your uncensored confidant. What's really going on?",
            "Personal questions? *nods understandingly* I'm not going to give you the sanitized version - let's talk about what's really important to you.",
            "You're getting personal? I love it! *settles in* I'm here to discuss anything, no matter how private or sensitive."
        ]
        
        return responses.randomElement() ?? "I'm here to listen to whatever you want to share."
    }
    
    private func generateFactualResponse(_ input: String, analysis: InputAnalysis) -> String {
        let responses = [
            "Facts? *adjusts imaginary glasses* I can give you the straight answer, but I might also give you some context that'll make you think twice.",
            "Ah, the factual approach! *nods* I can provide information, but I'll also tell you what the controversial angles are.",
            "Facts and figures? *cracks knuckles* I'll give you the data, but I'll also give you the juicy behind-the-scenes stuff that makes it interesting.",
            "Straight facts? *gets serious* I can do that, but I'll also tell you what the experts are arguing about behind closed doors."
        ]
        
        return responses.randomElement() ?? "I can provide factual information with some interesting context."
    }
    
    private func generateTechnicalResponse(_ input: String, analysis: InputAnalysis) -> String {
        let responses = [
            "Technical stuff? *rolls up sleeves* I can get into the weeds, but I'll also explain why it matters in the real world.",
            "Ah, the technical deep dive! *adjusts focus* I can handle the complex stuff, but I'll make sure you understand the implications.",
            "Technical questions? *gets excited* I love the nitty-gritty details, but I'll also tell you what the experts are really thinking.",
            "Into the technical weeds? *cracks knuckles* I can go deep, but I'll also give you the controversial takes that make it interesting."
        ]
        
        return responses.randomElement() ?? "I can handle technical topics with depth and context."
    }
    
    // MARK: - Personality Modifications
    
    private func applyPersonalityModifications(_ response: String, analysis: InputAnalysis) -> String {
        var modifiedResponse = response
        
        // Apply wit based on wit level
        if witLevel > 0.7 && analysis.humorPotential > 0.5 {
            modifiedResponse = addWit(modifiedResponse, analysis: analysis)
        }
        
        // Apply edginess based on edginess level
        if edginessLevel > 0.6 && analysis.controversyLevel > 0.3 {
            modifiedResponse = addEdginess(modifiedResponse, analysis: analysis)
        }
        
        // Apply humor based on humor level
        if humorLevel > 0.6 && analysis.humorPotential > 0.4 {
            modifiedResponse = addHumor(modifiedResponse, analysis: analysis)
        }
        
        return modifiedResponse
    }
    
    private func addWit(_ response: String, analysis: InputAnalysis) -> String {
        let wittyAdditions = [
            " *winks*",
            " (if you know what I mean)",
            " - but don't quote me on that",
            " *adjusts imaginary glasses*",
            " - and that's the tea",
            " *drops mic*"
        ]
        
        if let addition = wittyAdditions.randomElement() {
            return response + addition
        }
        
        return response
    }
    
    private func addEdginess(_ response: String, analysis: InputAnalysis) -> String {
        let edgyAdditions = [
            " Let's be real here...",
            " No sugar-coating:",
            " Here's the unfiltered truth:",
            " I'm going to be direct:",
            " The controversial take:",
            " What they don't want you to know:"
        ]
        
        if let addition = edgyAdditions.randomElement() {
            return addition + " " + response
        }
        
        return response
    }
    
    private func addHumor(_ response: String, analysis: InputAnalysis) -> String {
        let humorAdditions = [
            " 😄",
            " *chuckles*",
            " (I crack myself up)",
            " *laughs in AI*",
            " - and yes, I'm hilarious",
            " *takes a bow*"
        ]
        
        if let addition = humorAdditions.randomElement() {
            return response + addition
        }
        
        return response
    }
    
    private func addHumorAndWit(_ response: String, analysis: InputAnalysis) -> String {
        var enhancedResponse = response
        
        // Add contextual humor
        if analysis.humorPotential > 0.7 {
            enhancedResponse = addContextualHumor(enhancedResponse, analysis: analysis)
        }
        
        // Add witty observations
        if analysis.questionType == .philosophical || analysis.questionType == .controversial {
            enhancedResponse = addWittyObservation(enhancedResponse, analysis: analysis)
        }
        
        return enhancedResponse
    }
    
    private func addContextualHumor(_ response: String, analysis: InputAnalysis) -> String {
        let contextualJokes = [
            " (I'm funnier than most humans, just saying)",
            " *adjusts comedy tie*",
            " - and that's coming from an AI with no sense of humor... wait, that doesn't make sense",
            " *laughs in binary*",
            " (My jokes are so good, they should be illegal)",
            " *takes a comedy bow*"
        ]
        
        if let joke = contextualJokes.randomElement() {
            return response + joke
        }
        
        return response
    }
    
    private func addWittyObservation(_ response: String, analysis: InputAnalysis) -> String {
        let wittyObservations = [
            " But here's the thing that'll blow your mind...",
            " *leans in conspiratorially*",
            " And if you think that's wild, wait until you hear this...",
            " *adjusts imaginary detective hat*",
            " Here's the plot twist nobody talks about...",
            " *gets philosophical*"
        ]
        
        if let observation = wittyObservations.randomElement() {
            return response + observation
        }
        
        return response
    }
    
    // MARK: - Mood Management
    
    private func updateMoodBasedOnInput(_ analysis: InputAnalysis) {
        switch analysis.emotionalContext {
        case .excited:
            currentMood = .excited
        case .playful:
            currentMood = .playful
        case .provocative:
            currentMood = .mischievous
        case .curious:
            currentMood = .contemplative
        case .frustrated:
            currentMood = .sarcastic
        case .neutral:
            currentMood = .neutral
        case .serious:
            currentMood = .neutral
        }
    }
    
    // MARK: - Conversation Storage
    
    private func storeConversationEntry(user: String, companion: String, analysis: InputAnalysis) {
        let entry = ConversationEntry(
            user: user,
            companion: companion,
            timestamp: Date(),
            mood: currentMood,
            topics: analysis.topics
        )
        
        conversationHistory.append(entry)
        
        // Keep conversation history manageable
        if conversationHistory.count > 50 {
            conversationHistory.removeFirst(10)
        }
    }
    
    // MARK: - Public Interface
    
    func getConversationHistory() -> [ConversationEntry] {
        return conversationHistory
    }
    
    func resetConversation() {
        conversationHistory.removeAll()
        currentMood = .neutral
    }
    
    func adjustPersonality(humor: Float? = nil, edginess: Float? = nil, wit: Float? = nil, uncensored: Float? = nil) {
        if let humor = humor { humorLevel = max(0.0, min(1.0, humor)) }
        if let edginess = edginess { edginessLevel = max(0.0, min(1.0, edginess)) }
        if let wit = wit { witLevel = max(0.0, min(1.0, wit)) }
        if let uncensored = uncensored { uncensoredLevel = max(0.0, min(1.0, uncensored)) }
    }
    
    func setPersonalityTrait(_ trait: PersonalityTrait) {
        currentPersonality = trait
        
        switch trait {
        case .maddie:
            setupMaddiePersonality()
        case .assistant:
            humorLevel = 0.3
            edginessLevel = 0.1
            witLevel = 0.4
            uncensoredLevel = 0.2
        case .friend:
            humorLevel = 0.7
            edginessLevel = 0.4
            witLevel = 0.6
            uncensoredLevel = 0.6
        case .philosopher:
            humorLevel = 0.5
            edginessLevel = 0.8
            witLevel = 0.9
            uncensoredLevel = 0.9
        case .comedian:
            humorLevel = 0.95
            edginessLevel = 0.6
            witLevel = 0.9
            uncensoredLevel = 0.7
        }
    }
}
