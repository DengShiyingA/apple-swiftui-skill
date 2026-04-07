# Apple NATURALLANGUAGE Skill


## Finding similarities between pieces of text
> https://developer.apple.com/documentation/naturallanguage/finding-similarities-between-pieces-of-text

### 
#### 
3. To find the distance between your input word and another word, use `distance(between:and:distanceType:)`.
3. To find the distance between your input word and another word, use `distance(between:and:distanceType:)`.
4. To find the nearest neighbors to your input word, enumerate over the word’s neighbors by calling the  method, specifying the maximum number of nearest neighbors to look at.
```swift
if let embedding = NLEmbedding.wordEmbedding(for: .english) {
    let word = "bicycle"
    
    if let vector = embedding.vector(for: word) {
        print(vector)
    }
    
    let specificDistance = embedding.distance(between: word, and: "motorcycle")
    print(specificDistance.description)
    
    embedding.enumerateNeighbors(for: word, maximumCount: 5) { neighbor, distance in
        print("\(neighbor): \(distance.description)")
        return true
    }
}
```

#### 
2. Call the  method of the embedding with a specific input sentence to see the vector generated for that sentence.
3. To find the distance between your input sentence and another sentence, use .
```swift
if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
    let sentence = "This is a sentence."

    if let vector = sentenceEmbedding.vector(for: sentence) {
        print(vector)
    }
    
    let distance = sentenceEmbedding.distance(between: sentence, and: "That is a sentence.")
    print(distance.description)
}
```


## Identifying parts of speech
> https://developer.apple.com/documentation/naturallanguage/identifying-parts-of-speech

### 
Identifying the parts of speech for words in natural language text can help your program understand the meaning of sentences. For example, provided the transcription of a request spoken by the user, you might programmatically determine general intent by looking at only the nouns and verbs.
The example below shows how to use NLTagger to enumerate over natural language text and identify the part of speech for each word.
```swift
let text = "The ripe taste of cheese improves with age."
let tagger = NLTagger(tagSchemes: [.lexicalClass])
tagger.string = text
let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
    if let tag = tag {
        print("\(text[tokenRange]): \(tag.rawValue)")
    }
    return true
}
```

5. In the enumeration block, take a substring of the original text at `tokenRange` to obtain each word.

## Identifying people, places, and organizations
> https://developer.apple.com/documentation/naturallanguage/identifying-people-places-and-organizations

### 
6. To return multiple possible tags and their associated confidence scores, in the enumeration block, call the  method.
7. Run the following code to print out each name and its type, as well as other possible tags and their probabilities, on a new line.
```swift
let text = "The American Red Cross was established in Washington, D.C., by Clara Barton."

let tagger = NLTagger(tagSchemes: [.nameType])
tagger.string = text

let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
let tags: [NLTag] = [.personalName, .placeName, .organizationName]

tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in 
    // Get the most likely tag, and print it if it's a named entity.
    if let tag = tag, tags.contains(tag) {
        print("\(text[tokenRange]): \(tag.rawValue)")
    }
        
    // Get multiple possible tags with their associated confidence scores.
    let (hypotheses, _) = tagger.tagHypotheses(at: tokenRange.lowerBound, unit: .word, scheme: .nameType, maximumCount: 1)
    print(hypotheses)
        
   return true
}
```


## Identifying the language in text
> https://developer.apple.com/documentation/naturallanguage/identifying-the-language-in-text

### 
#### 
To set up a language recognizer, create an instance of . Call its  method with the input text you want to perform language identification for. If your text has multiple parts that you want to analyze together, call  with an input string for each part before you ask for the language prediction.
```swift
// Create a language recognizer.
let recognizer = NLLanguageRecognizer()
recognizer.processString("This is a test, mein Freund.")
```

#### 
To get the most likely language for the provided input text, access the language recognizer’s  property. This property is an optional value, so make sure to handle the case where the language recognizer can’t identify a dominant language.
```swift
// Identify the dominant language.
if let language = recognizer.dominantLanguage {
    print(language.rawValue)
} else {
    print("Language not recognized")
}
```

#### 
To generate multiple possible language predictions, use the  method. Specify the maximum number of possible languages to identify.
```swift
// Generate up to two language hypotheses.
let hypotheses = recognizer.languageHypotheses(withMaximum: 2)
print(hypotheses)
```

#### 
- A list of languages the predictions are constrained against
- A list of known probabilities for some or all languages
```swift
// Specify constraints for language identification.
recognizer.languageConstraints = [.french, .english, .german,
                                  .italian, .spanish, .portuguese]

recognizer.languageHints = [.french: 0.5,
                            .english: 0.9,
                            .german: 0.8,
                            .italian: 0.6,
                            .spanish: 0.3,
                            .portuguese: 0.2]

let constrainedHypotheses = recognizer.languageHypotheses(withMaximum: 2)
print(constrainedHypotheses)
```

#### 
If you have distinct pieces of text whose languages you want to identify separately, you need to reset the recognizer before processing the next string. Resetting the language recognizer returns it to its initial state, removing any input strings, language constraints, and hints that you previously provided.
```swift
// Reset the recognizer to its initial state.
recognizer.reset()

// Process additional strings for language identification.
recognizer.processString("Este es un idioma diferente.")
```


## Tokenizing natural language text
> https://developer.apple.com/documentation/naturallanguage/tokenizing-natural-language-text

### 
When you work with natural language text, it’s often useful to tokenize the text into individual words. Using  to enumerate words, rather than simply splitting components by whitespace, ensures correct behavior in multiple scripts and languages. For example, neither Chinese nor Japanese uses spaces to delimit words.
The example and accompanying steps below show how you use  to enumerate over the words in natural language text.
```swift
let text = """
All human beings are born free and equal in dignity and rights.
They are endowed with reason and conscience and should act towards one another in a spirit of brotherhood.
"""

let tokenizer = NLTokenizer(unit: .word)
tokenizer.string = text

tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
    print(text[tokenRange])
    return true
}
```

4. In the enumeration block, take a substring of the original text at `tokenRange` to obtain each word.

