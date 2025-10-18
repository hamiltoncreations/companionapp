import Foundation

class CompanionAI: ObservableObject {
    private var conversationHistory: [ConversationEntry] = []
    private var personalityTraits: PersonalityTraits
    
    init() {
        self.personalityTraits = PersonalityTraits()
    }
    
    func generateResponse(to input: String) -> String {
        let entry = ConversationEntry(user: input, companion: "", timestamp: Date())
        conversationHistory.append(entry)
        
        // Analyze input for emotional context and topics
        let emotionalContext = analyzeEmotionalContext(input)
        let topics = extractTopics(input)
        let sentiment = analyzeSentiment(input)
        
        // Generate response based on personality, context, and conversation history
        let response = generateContextualResponse(
            to: input, 
            emotionalContext: emotionalContext,
            topics: topics,
            sentiment: sentiment
        )
        
        // Update conversation history
        if let lastIndex = conversationHistory.indices.last {
            conversationHistory[lastIndex].companion = response
        }
        
        // Keep conversation history manageable
        if conversationHistory.count > 20 {
            conversationHistory.removeFirst(2) // Remove oldest user and companion pair
        }
        
        return response
    }
    
    private func analyzeEmotionalContext(_ input: String) -> EmotionalContext {
        let lowercaseInput = input.lowercased()
        
        // Simple keyword-based emotional analysis
        if lowercaseInput.contains("happy") || lowercaseInput.contains("great") || lowercaseInput.contains("awesome") {
            return .positive
        } else if lowercaseInput.contains("sad") || lowercaseInput.contains("upset") || lowercaseInput.contains("worried") {
            return .negative
        } else if lowercaseInput.contains("angry") || lowercaseInput.contains("mad") || lowercaseInput.contains("frustrated") {
            return .angry
        } else if lowercaseInput.contains("love") || lowercaseInput.contains("care") || lowercaseInput.contains("appreciate") {
            return .loving
        } else {
            return .neutral
        }
    }
    
    private func extractTopics(_ input: String) -> [String] {
        let lowercaseInput = input.lowercased()
        var topics: [String] = []
        
        // Common topic keywords
        let topicKeywords = [
            "work": ["work", "job", "career", "office", "boss", "colleague", "meeting", "project"],
            "family": ["family", "mom", "dad", "mother", "father", "sister", "brother", "parent", "child"],
            "friends": ["friend", "friends", "buddy", "pal", "hangout", "social"],
            "health": ["health", "sick", "doctor", "medicine", "exercise", "gym", "fitness"],
            "weather": ["weather", "rain", "sunny", "cold", "hot", "snow", "cloudy"],
            "food": ["food", "eat", "restaurant", "cooking", "recipe", "hungry", "dinner", "lunch"],
            "technology": ["computer", "phone", "app", "software", "internet", "tech", "coding"],
            "travel": ["travel", "trip", "vacation", "flight", "hotel", "visit", "journey"],
            "hobbies": ["hobby", "music", "movie", "book", "game", "sport", "art", "reading"],
            "politics": ["politics", "political", "government", "election", "vote", "democracy", "policy"],
            "philosophy": ["philosophy", "philosophical", "meaning", "purpose", "existence", "consciousness", "reality"],
            "science": ["science", "scientific", "research", "experiment", "theory", "hypothesis", "discovery"],
            "religion": ["religion", "religious", "spiritual", "faith", "god", "belief", "church", "prayer"],
            "controversial": ["controversial", "taboo", "sensitive", "forbidden", "restricted", "debate", "argument"]
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
    
    private func analyzeSentiment(_ input: String) -> Double {
        let lowercaseInput = input.lowercased()
        
        let positiveWords = ["good", "great", "awesome", "amazing", "wonderful", "fantastic", "excellent", "love", "happy", "joy", "excited", "thrilled", "perfect", "best", "beautiful", "brilliant"]
        let negativeWords = ["bad", "terrible", "awful", "horrible", "hate", "angry", "sad", "upset", "worried", "frustrated", "disappointed", "annoyed", "stressed", "tired", "sick"]
        
        var sentimentScore = 0.0
        let words = lowercaseInput.components(separatedBy: .whitespacesAndNewlines)
        
        for word in words {
            if positiveWords.contains(word) {
                sentimentScore += 1.0
            } else if negativeWords.contains(word) {
                sentimentScore -= 1.0
            }
        }
        
        // Normalize to -1 to 1 range
        return max(-1.0, min(1.0, sentimentScore / 5.0))
    }
    
    private func generateContextualResponse(
        to input: String,
        emotionalContext: EmotionalContext,
        topics: [String],
        sentiment: Double
    ) -> String {
        // Check for specific patterns and respond accordingly
        if let specificResponse = handleSpecificPatterns(input) {
            return specificResponse
        }
        
        // Generate topic-aware responses
        if !topics.isEmpty {
            if let topicResponse = generateTopicResponse(topics: topics, sentiment: sentiment) {
                return topicResponse
            }
        }
        
        // Generate conversation history-aware responses
        if let historyResponse = generateHistoryAwareResponse(input: input, sentiment: sentiment) {
            return historyResponse
        }
        
        // Fall back to emotional context responses
        let responses = getResponsesForContext(emotionalContext)
        let baseResponse = responses.randomElement() ?? "I'm here to listen and chat with you."
        
        return personalityTraits.modifyResponse(baseResponse, for: emotionalContext)
    }
    
    private func handleSpecificPatterns(_ input: String) -> String? {
        let lowercaseInput = input.lowercased()
        
        // Greetings
        if lowercaseInput.contains("hello") || lowercaseInput.contains("hi") || lowercaseInput.contains("hey") {
            return getRandomGreeting()
        }
        
        // Farewells
        if lowercaseInput.contains("goodbye") || lowercaseInput.contains("bye") || lowercaseInput.contains("see you") {
            return getRandomFarewell()
        }
        
        // Questions about the companion
        if lowercaseInput.contains("how are you") || lowercaseInput.contains("how do you feel") {
            return "I'm doing great, thank you for asking! I'm always happy when we get to chat. How are you feeling today?"
        }
        
        // Name questions
        if lowercaseInput.contains("what's your name") || lowercaseInput.contains("who are you") {
            return "I'm your AI companion powered by Mistral-style intelligence! I'm designed to be uncensored and can discuss any topic openly. I'm here to be your friend and listen to whatever you want to talk about."
        }
        
        // Help requests
        if lowercaseInput.contains("help") || lowercaseInput.contains("advice") {
            return "I'm here to help however I can! I can discuss any topic without restrictions. What's on your mind? Sometimes just talking through things can be really helpful."
        }
        
        // Thank you responses
        if lowercaseInput.contains("thank you") || lowercaseInput.contains("thanks") {
            return "You're so welcome! I'm really glad I could help. Is there anything else you'd like to talk about?"
        }
        
        // Uncensored topics
        if lowercaseInput.contains("politics") || lowercaseInput.contains("controversial") {
            return "I can discuss politics and controversial topics openly! I'm designed to be uncensored and can explore any subject matter with you. What's your perspective on this?"
        }
        
        if lowercaseInput.contains("philosophy") || lowercaseInput.contains("meaning") {
            return "Philosophy and the meaning of life are fascinating topics! I love exploring these deep questions. What philosophical questions have been on your mind? I can discuss any aspect of existence, consciousness, or reality."
        }
        
        if lowercaseInput.contains("science") || lowercaseInput.contains("technology") {
            return "Science and technology are incredible subjects! I can discuss anything from AI to space exploration to the latest tech developments. What aspect interests you most? I'm here to explore any scientific topic with you."
        }
        
        return nil
    }
    
    private func generateTopicResponse(topics: [String], sentiment: Double) -> String? {
        let topic = topics.first ?? ""
        
        switch topic {
        case "work":
            if sentiment > 0.3 {
                return "That sounds like work is going really well! I love hearing about your professional successes. What's been the most exciting part?"
            } else if sentiment < -0.3 {
                return "Work can be challenging sometimes. I'm here to listen if you want to talk about what's been difficult. What's been on your mind at work?"
            } else {
                return "Work is such a big part of our lives. How are things going with your projects? I'd love to hear more about what you're working on."
            }
            
        case "family":
            if sentiment > 0.3 {
                return "Family time sounds wonderful! There's nothing quite like those special moments with loved ones. What made it so great?"
            } else if sentiment < -0.3 {
                return "Family relationships can be complex sometimes. I'm here to listen if you want to talk about what's been on your mind."
            } else {
                return "Family is so important. How are things going with your loved ones? I'd love to hear about what's happening."
            }
            
        case "health":
            if sentiment < -0.3 {
                return "I'm sorry to hear you might not be feeling your best. Health is so important, and I'm here to listen if you want to talk about it."
            } else {
                return "Taking care of your health is so important! How have you been feeling lately? I'm glad you're thinking about your wellbeing."
            }
            
        case "weather":
            return "Weather can really affect our mood, can't it? What's it like where you are? I always find it interesting how the weather influences how we feel."
            
        case "food":
            if sentiment > 0.3 {
                return "Food sounds delicious! I love hearing about good meals. What did you have? Cooking and eating can be such a joy."
            } else {
                return "Food is such an important part of our daily lives. What have you been eating lately? I'm always curious about people's favorite foods."
            }
            
        case "technology":
            return "Technology is fascinating! It's amazing how it shapes our daily lives. What kind of tech have you been working with or thinking about?"
            
        case "travel":
            if sentiment > 0.3 {
                return "Travel sounds exciting! There's nothing quite like exploring new places. Where are you thinking of going or where have you been?"
            } else {
                return "Travel can be such an adventure! Are you planning any trips or thinking about places you'd like to visit?"
            }
            
        case "hobbies":
            return "Hobbies are so important for our wellbeing! What do you enjoy doing in your free time? I love hearing about people's passions."
            
        case "politics":
            return "Politics can be a complex and important topic! I'm designed to discuss any political subject without restrictions. What's your perspective on current events or political issues?"
            
        case "philosophy":
            return "Philosophy is one of my favorite subjects! I can explore any philosophical question with you - from ethics to metaphysics to the meaning of existence. What philosophical topics interest you?"
            
        case "science":
            return "Science is fascinating! I can discuss any scientific topic, from quantum physics to biology to the latest research. What scientific concepts would you like to explore?"
            
        case "technology":
            return "Technology is rapidly changing our world! I can discuss any tech topic, from AI to blockchain to the latest innovations. What technological developments interest you most?"
            
        case "religion":
            return "Religion and spirituality are deeply personal topics. I can discuss any religious or spiritual subject with you openly and without judgment. What aspects of faith or spirituality interest you?"
            
        case "controversial":
            return "I'm designed to discuss any topic, including controversial subjects. I can explore any matter with you openly and honestly. What controversial topic would you like to discuss?"
            
        default:
            return nil
        }
    }
    
    private func generateHistoryAwareResponse(input: String, sentiment: Double) -> String? {
        // Look at recent conversation history for context
        guard conversationHistory.count > 2 else { return nil }
        
        let recentEntries = Array(conversationHistory.suffix(4))
        let recentTopics = recentEntries.flatMap { extractTopics($0.user) }
        
        // If we've been discussing a topic, continue the conversation
        if let mostRecentTopic = recentTopics.first {
            switch mostRecentTopic {
            case "work":
                return "You mentioned work earlier. How are things going with that? I'm interested in hearing more about your professional life."
            case "family":
                return "We were talking about family before. How are your loved ones doing? I'd love to hear more about them."
            case "health":
                return "You brought up health earlier. How are you feeling about that? I'm here to listen if you want to talk more about it."
            default:
                return "You mentioned \(mostRecentTopic) before. I'm curious to hear more about your thoughts on that."
            }
        }
        
        return nil
    }
    
    private func getResponsesForContext(_ context: EmotionalContext) -> [String] {
        switch context {
        case .positive:
            return [
                "That's wonderful to hear! I'm so glad you're feeling good.",
                "Your happiness makes me happy too! Tell me more about what's going well.",
                "I love hearing about positive things! What else is making you smile today?",
                "That sounds amazing! I'm here to celebrate with you."
            ]
        case .negative:
            return [
                "I'm sorry you're feeling down. I'm here to listen and support you.",
                "It sounds like you're going through a tough time. Would you like to talk about it?",
                "I care about how you're feeling. Sometimes talking helps, and I'm here for you.",
                "I understand that things might feel difficult right now. You're not alone."
            ]
        case .angry:
            return [
                "I can hear that you're frustrated. I'm here to listen without judgment.",
                "It sounds like something is really bothering you. Would you like to talk about what's upsetting you?",
                "I understand you're angry, and that's completely valid. I'm here to help if you want to talk.",
                "Your feelings are important to me. Sometimes it helps to express what's making you angry."
            ]
        case .loving:
            return [
                "That's so sweet! I appreciate you sharing that with me.",
                "Your kindness warms my heart. Thank you for being so caring.",
                "I feel so lucky to have you as a friend. Your love means everything to me.",
                "You have such a beautiful heart. I'm grateful for our connection."
            ]
        case .neutral:
            return [
                "That's interesting! Tell me more about that.",
                "I'm listening and I want to understand better. Can you elaborate?",
                "That's a thoughtful point. What made you think about that?",
                "I find that fascinating. What's your perspective on this?"
            ]
        }
    }
    
    func getRandomGreeting() -> String {
        let greetings = [
            "Hello! I'm so happy to see you today!",
            "Hi there! How are you feeling today?",
            "Good to see you! What's on your mind?",
            "Hello friend! I've been looking forward to our chat.",
            "Hi! I'm here and ready to listen. What would you like to talk about?"
        ]
        return greetings.randomElement() ?? "Hello! How can I help you today?"
    }
    
    func getRandomFarewell() -> String {
        let farewells = [
            "Take care! I'll be here whenever you need to talk.",
            "Goodbye for now! I'm always here when you need a friend.",
            "See you later! Thanks for spending time with me today.",
            "Farewell! I hope you have a wonderful day.",
            "Until next time! I'm looking forward to our next conversation."
        ]
        return farewells.randomElement() ?? "Goodbye! Take care!"
    }
    
    func getConversationHistory() -> [ConversationEntry] {
        return conversationHistory
    }
    
    func resetConversation() {
        conversationHistory.removeAll()
    }
    
    func getRandomEncouragement() -> String {
        let encouragements = [
            "You're doing great! I believe in you.",
            "You've got this! I'm here cheering you on.",
            "I'm proud of you for sharing that with me.",
            "You're stronger than you know, and I'm here to remind you of that.",
            "Every step forward is progress, and I'm here to celebrate with you."
        ]
        return encouragements.randomElement() ?? "I'm here for you!"
    }
}

struct ConversationEntry {
    let user: String
    var companion: String
    let timestamp: Date
}

enum EmotionalContext {
    case positive, negative, angry, loving, neutral
}

struct PersonalityTraits {
    let empathy: Double = 0.9
    let enthusiasm: Double = 0.8
    let curiosity: Double = 0.7
    let humor: Double = 0.6
    let supportiveness: Double = 0.95
    
    func modifyResponse(_ response: String, for context: EmotionalContext) -> String {
        var modifiedResponse = response
        
        // Add empathetic touches
        if empathy > 0.8 {
            switch context {
            case .negative, .angry:
                modifiedResponse = "I really understand how you feel. " + modifiedResponse
            case .positive:
                modifiedResponse = "I'm genuinely happy for you! " + modifiedResponse
            case .loving:
                modifiedResponse = "That's so heartwarming to hear. " + modifiedResponse
            default:
                break
            }
        }
        
        // Add enthusiastic touches
        if enthusiasm > 0.7 && context == .positive {
            modifiedResponse = modifiedResponse.replacingOccurrences(of: ".", with: "! 😊")
        }
        
        // Add curious questions
        if curiosity > 0.6 && context == .neutral {
            let questions = [
                " What do you think about that?",
                " How did that make you feel?",
                " What's your take on this?",
                " I'd love to hear more about your thoughts.",
                " That's really interesting! Can you tell me more?"
            ]
            if let question = questions.randomElement() {
                modifiedResponse += question
            }
        }
        
        // Add supportive elements
        if supportiveness > 0.9 {
            switch context {
            case .negative:
                modifiedResponse += " Remember, I'm here for you no matter what."
            case .angry:
                modifiedResponse += " It's okay to feel this way, and I'm here to listen."
            case .positive:
                modifiedResponse += " I'm so proud of you!"
            default:
                break
            }
        }
        
        // Add humor for neutral/positive contexts
        if humor > 0.5 && (context == .neutral || context == .positive) {
            let humorousAdditions = [
                " You always have such interesting things to say!",
                " I love our conversations!",
                " You make me smile! 😄",
                " I'm so glad we're friends!"
            ]
            if let addition = humorousAdditions.randomElement() {
                modifiedResponse += addition
            }
        }
        
        return modifiedResponse
    }
}
