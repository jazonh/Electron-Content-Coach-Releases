# 📖 Electron Content Coach - Usage Guide

## 🎯 Overview

Electron Content Coach is a desktop application that helps TCGplayer employees write on-brand communications using AI-powered tone correction and content generation.

## 🚀 Getting Started

### Initial Setup

1. **Launch the App**: Open "Electron Next App" from your Applications folder
2. **Configure Environment**: Ensure your `.env` file contains:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_key
   ```
3. **Verify PyChomsky**: The app will initialize PyChomsky on startup

## 🎨 Main Interface

The app features a modern, animated interface with several key sections:

### 1. Mode Selection
Choose between two modes:
- **Correct Text**: Revise existing text to match brand guidelines
- **Generate Text**: Create new content from a description

### 2. Target Audience
Select who you're writing for:
- **Buyers**: Close, knowledgeable friend at the local game store
- **Sellers**: Close, reliable business partner

### 3. Input Area
- **Correct Mode**: Paste the text you want to improve
- **Generate Mode**: Describe what content you need

### 4. Processing Steps
Watch the AI workflow in real-time:
1. **Analyzing Input** - Understanding your request
2. **Finding Guidelines** - Searching brand guidelines via RAG
3. **Generating Response** - Creating on-brand content with GPT-5 Mini
4. **Finalizing** - Preparing results

### 5. Results Section

#### Primary Output
The main corrected/generated text appears first with smooth animations.

#### Rationale
See the AI's decision-making process:
- Which guidelines were applied
- Why specific changes were made
- Reasoning behind the tone adjustments

#### Alternative Versions
Get 3 variants with different approaches:
- Each labeled with its strategy (e.g., "Concise & Direct", "Supportive & Clear")
- Choose the version that best fits your needs
- Learn different ways to express the same idea

#### Cited Sources
See which brand guidelines influenced the output:
- Guideline file name
- Specific section referenced
- Similarity match percentage
- Preview of the guideline content

## 🎯 Use Cases

### Error Messages
**Input**: "Sorry, we couldn't load your cart. Please try again."
**Mode**: Correct Text
**Audience**: Buyers

The app will:
- Remove unnecessary apologies (following guideline: no apologies for minor issues)
- Apply canonical structure: [What happened] + [What to do next]
- Use sentence case only
- Make it concise and direct

**Expected Output**: "We can't load your cart right now. Try again later."

### Product Announcements
**Input**: "Describe a new feature that lets users track their recent purchases"
**Mode**: Generate Text
**Audience**: Buyers

The app will:
- Generate buyer-focused, friendly language
- Apply TCGplayer voice characteristics
- Create 3 different approaches
- Cite relevant brand guidelines

### Seller Communications
**Input**: "Your listing has been flagged for review"
**Mode**: Correct Text
**Audience**: Sellers

The app will:
- Apply professional, partner-like tone
- Be clear and neutral
- Avoid blame, focus on next steps
- Reference seller-specific guidelines

## 🔍 Understanding the RAG System

### How It Works
1. **Embedding**: Your input is converted to a vector using PyChomsky
2. **Search**: Supabase finds the most relevant guidelines (semantic search)
3. **Context**: Top 5 matching guidelines are sent to the LLM
4. **Generation**: GPT-5 Mini uses both universal and audience-specific style guides
5. **Output**: You get corrected text with rationale and citations

### Why RAG Matters
- **Relevance**: Only the most applicable guidelines are used
- **Transparency**: You see which guidelines influenced the output
- **Accuracy**: Semantic search finds conceptually similar guidelines, not just keyword matches
- **Efficiency**: 400K context window handles large style guides + retrieved guidelines

## 💡 Tips & Best Practices

### For Best Results
1. **Be Specific**: Include context about the communication type
2. **Choose Right Audience**: Buyer vs. Seller voice is significantly different
3. **Review Variants**: The alternatives often reveal better approaches
4. **Read Rationale**: Understand why changes were made to improve your writing
5. **Check Citations**: Learn which guidelines apply to your use case

### Common Patterns

**Error Messages**:
- Remove "please" for straightforward fixes
- No apologies for minor issues
- Use [What happened] + [What to do next] structure

**Calls to Action**:
- Be direct and clear
- Avoid passive voice
- Use action-oriented language

**Product Descriptions**:
- Focus on benefits, not just features
- Use conversational tone
- Match audience expectations

## 🔄 Workflow Integration

### Quick Corrections
1. Copy text from your work
2. Paste into Electron Content Coach
3. Select mode and audience
4. Review primary output
5. Copy back to your work

### Learning Tool
1. Input various examples
2. Study the rationale
3. Review cited guidelines
4. Compare alternatives
5. Internalize brand voice

### Template Generation
1. Describe the communication need
2. Use Generate mode
3. Get multiple approaches
4. Adapt the best fit
5. Save as template

## 🆘 Troubleshooting

### No Results
- Check internet connection
- Verify Supabase credentials in `.env`
- Ensure PyChomsky is initialized (check console)

### Unexpected Output
- Try being more specific in your input
- Review the cited sources to understand context
- Try different mode (Correct vs. Generate)

### Performance Issues
- GPT-5 Mini is a reasoning model (may take longer)
- RAG search adds ~1-2 seconds for guideline retrieval
- Close other intensive applications

## 📚 Learning Resources

### Built-in Guidelines
The app includes comprehensive style guides:
- **Universal**: General writing principles for all TCGplayer content
- **Buyer Voice**: Specific tone and style for buyer-facing content
- **Seller Voice**: Specific tone and style for seller-facing content

### Cited Sources
Pay attention to which guidelines appear most often for your use cases - these are the core principles.

---

**Need Help?** Contact the development team or check the main repository for more documentation.
