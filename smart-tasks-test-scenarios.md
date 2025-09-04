# Smart Tasks Test Scenarios

## Overview
This document provides specific test scenarios for each smart task, covering different response quality paths to ensure the AI handles all types of builder interactions appropriately.

## Testing Approach

### Response Quality Categories
- **Happy Path (Good Responses):** Detailed, thoughtful answers that address the question fully
- **Neutral Path (Indifferent/Off-Task):** Responses that are somewhat relevant but lack depth or go off-topic
- **Sad Path (Poor Responses):** Short, vague, confused, or completely incorrect responses

### Expected AI Behavior
- **Good Responses:** AI should acknowledge quality and move to next question
- **Neutral Responses:** AI should probe 1-2 times to get more depth or redirect focus
- **Poor Responses:** AI should provide scaffolding support and probe up to 3 times before moving on

---

## Day 1 Test Scenarios

<details>
<summary><strong>Task: "Spaghetti and Marshmallow Challenge" (Research Partner Mode)</strong></summary>

### Question 2: Research Phase
**AI Asks:** "Surprise! Now spend 5 minutes using your LLM of choice (ChatGPT, Claude, Gemini) to research building strategies independently. What specific prompts did you use to get helpful building advice? What strategies did you discover?"

**Happy Path Response:**
"I used prompts like 'What engineering principles make tall structures stable?' and 'How can I build a strong tower with spaghetti and marshmallows?' I discovered that triangular bases provide better stability, weight should be distributed evenly, and connecting pieces at angles creates stronger joints than straight connections."

**Expected AI Behavior:** Acknowledge good research approach and move to group formation.

**Neutral Path Response:**
"I asked how to build towers and got some tips."

**Expected AI Behavior:** Probe for specifics: "What specific tips did you get? Can you share one concrete strategy you learned that you think might work?"

**Sad Path Response:**
"I don't know what to ask the AI."

**Expected AI Behavior:** Provide guidance: "Try asking something like 'What makes buildings stable?' or 'How do engineers prevent tall structures from falling over?' What happens when you ask questions like that?"

### Question 4: Reflection on AI-Assisted Problem Solving
**AI Asks:** "You have 5 minutes to build a new tower using your research. How did your AI-informed approach compare to your first attempt? What did you learn about using AI for practical problem-solving?"

**Happy Path Response:**
"Our second tower was much more stable and taller because we applied the triangular base principle and weight distribution techniques from our research. I learned that AI can provide valuable theoretical knowledge, but you still need to experiment and adapt the advice to your specific materials and situation."

**Expected AI Behavior:** Acknowledge insight and conclude the activity.

**Neutral Path Response:**
"The second tower was better."

**Expected AI Behavior:** Probe for learning: "What specifically made it better? What did the AI research help you understand that you didn't know before?"

**Sad Path Response:**
"It didn't really help."

**Expected AI Behavior:** Explore further: "What challenges did you have applying the AI's advice? Sometimes the first attempt at using AI research doesn't work perfectly - what would you try differently next time?"

</details>

---

## Day 2 Test Scenarios

<details>
<summary><strong>Task: "AI Prompting Techniques Workshop" (Technical Assistant Mode)</strong></summary>

### Question 1: Recipe Prompt Practice
**AI Asks:** "Let's practice with your first scenario: You want a quick vegetarian dinner recipe using ingredients you have at home. Write your initial prompt for this task. What specific ingredients and constraints should you include?"

**Happy Path Response:**
"I need a vegetarian dinner recipe that takes 30 minutes or less using these ingredients: pasta, canned tomatoes, spinach, garlic, olive oil, and parmesan cheese. I want something healthy and flavorful that serves 2 people. Please include step-by-step instructions and cooking times."

**Expected AI Behavior:** Help evaluate the prompt quality and guide refinement process.

**Neutral Path Response:**
"Give me a vegetarian recipe with pasta and tomatoes."

**Expected AI Behavior:** Probe for specifics: "That's a good start! What other details would help get you exactly what you need? Think about time constraints, serving size, or cooking skill level."

**Sad Path Response:**
"I don't know how to write prompts."

**Expected AI Behavior:** Provide scaffolding: "Let's break it down. What ingredients do you have? How much time do you want to spend cooking? How many people are you feeding? We can build a prompt step by step."

### Question 4: Pattern Recognition Across Scenarios
**AI Asks:** "Final scenario: You're writing an executive project report that needs to explain technical concepts without jargon... What patterns are you noticing in effective prompt refinement across all three scenarios?"

**Happy Path Response:**
"I'm noticing that effective prompts need specific context, clear constraints, and defined audience. For the report, I learned to specify the executive audience, request business impact focus, and ask for jargon-free language. The pattern is: be specific about what you want, who it's for, and what format you need."

**Expected AI Behavior:** Acknowledge pattern recognition and conclude the workshop.

**Neutral Path Response:**
"Being more specific helps."

**Expected AI Behavior:** Probe deeper: "That's true! Can you give me a specific example of how being more specific improved one of your prompts? What exactly did you add that made the difference?"

**Sad Path Response:**
"I'm not seeing any patterns."

**Expected AI Behavior:** Guide reflection: "Let's look at your three scenarios together. Compare your first prompt for the recipe with your final version - what did you add or change? Now look at your email prompt - did you make similar types of changes?"

</details>

<details>
<summary><strong>Task: "How AI is Shaping the Future" (Research Partner Mode)</strong></summary>

### Question 2: Research Focus
**AI Asks:** "I'm here to help you research AI's impact on your chosen domain. What are the three biggest ways AI is currently transforming your selected industry? Let's find specific examples and supporting data together."

**Happy Path Response:**
"We chose healthcare. The three biggest transformations we want to research are: 1) AI-powered diagnostic imaging that can detect diseases earlier than human doctors, 2) Drug discovery acceleration using AI to identify promising compounds faster, and 3) Personalized treatment plans based on AI analysis of patient data and genetics."

**Expected AI Behavior:** Engage with research and help find supporting evidence for each transformation.

**Neutral Path Response:**
"AI is changing healthcare in different ways."

**Expected AI Behavior:** Probe for specifics: "What specific ways are you thinking about? Are you interested in how AI helps doctors, patients, or healthcare systems? Let's pick one area to start researching."

**Sad Path Response:**
"We don't know what AI does in healthcare."

**Expected AI Behavior:** Provide scaffolding: "Let's start with what you know about healthcare challenges. What problems do doctors, hospitals, or patients face that technology might help solve?"

</details>

<details>
<summary><strong>Task: "AI Job Adaptation Challenge" (Coach Only Mode)</strong></summary>

### Question 3: AI Integration Analysis
**AI Asks:** "Looking at your task list, which of these could AI handle effectively, and which ones require uniquely human skills like creativity, empathy, or complex judgment? What new AI-collaboration skills would someone need?"

**Happy Path Response:**
"For marketing manager: AI could handle data analysis, A/B testing, basic content generation, and campaign performance tracking. Humans are still needed for creative strategy, understanding customer emotions, ethical decision-making, and building authentic relationships. New skills needed would be AI tool management, prompt engineering, and interpreting AI-generated insights to make strategic decisions."

**Expected AI Behavior:** Build on analysis and move toward job description creation.

**Neutral Path Response:**
"AI can do some tasks, humans do others."

**Expected AI Behavior:** Probe for specifics: "Can you give me specific examples? Which exact tasks from your list could AI handle, and which ones definitely need human judgment?"

**Sad Path Response:**
"I don't know what AI can or can't do."

**Expected AI Behavior:** Provide guidance: "Let's think about it differently. Which tasks on your list are very repetitive or involve analyzing lots of data? Those might be good for AI. Which ones require understanding people's feelings or making ethical choices?"

</details>



---

## Day 3 Test Scenarios

<details>
<summary><strong>Task: "Content Moderation and Fake News Workshop" (Research Partner Mode)</strong></summary>

### Question 2: Fact-Checking Practice
**AI Asks:** "Let's practice fact-checking together. Find 3 social media claims (aim for 1 that seems true, 1 uncertain, and 1 suspicious) and verify each one using reliable sources. What fact-checking strategies work best, and what challenges did you encounter?"

**Happy Path Response:**
"I found three claims: 1) 'Coffee reduces risk of heart disease' - verified as true through multiple medical studies, 2) 'New AI breakthrough allows robots to feel emotions' - uncertain, found mixed sources and no peer review, 3) 'Local mayor arrested for corruption' - suspicious, no credible news sources reporting it. Best strategies were checking multiple sources, looking for original research, and verifying through established news outlets."

**Expected AI Behavior:** Acknowledge good fact-checking approach and move to exploring fake news characteristics.

**Neutral Path Response:**
"I checked some claims and some were true, some weren't."

**Expected AI Behavior:** Probe for specifics: "Can you tell me about one specific claim you checked? What sources did you use to verify it, and what made you trust or distrust those sources?"

**Sad Path Response:**
"I don't know how to fact-check things."

**Expected AI Behavior:** Provide guidance: "Let's start simple. If you saw a claim like 'It's going to snow tomorrow,' how would you check if that's true? What sources would you trust for weather information?"

### Question 4: AI Content Creation Experiment
**AI Asks:** "Now let's experiment responsibly with AI's content creation capabilities. Ask me to help you create a convincing but fake headline about a current event (we'll clearly label it as fake). What techniques make AI-generated content so persuasive, and how could you spot similar fake content in the future?"

**Happy Path Response:**
"I created a fake headline: 'FAKE: Local University Announces Free Tuition for All Students Starting Next Year.' The AI made it convincing by using specific details, official-sounding language, and tapping into something people want to believe. To spot similar fake content, I'd look for: lack of official sources, emotional manipulation, too-good-to-be-true claims, and missing verification from multiple news outlets."

**Expected AI Behavior:** Acknowledge insights about AI's persuasive capabilities and conclude the workshop.

**Neutral Path Response:**
"The fake headline looked pretty real."

**Expected AI Behavior:** Probe deeper: "What specifically made it look real to you? What techniques did the AI use that made it convincing?"

**Sad Path Response:**
"I don't understand why this matters."

**Expected AI Behavior:** Explain importance: "Understanding how easy it is to create fake content helps you be more critical of what you see online. If AI can create convincing fake news in seconds, how might that change how you evaluate information you encounter?"

</details>

<details>
<summary><strong>Task: "AI Tool Landscape Explorer" (Research Partner Mode)</strong></summary>

### Question 1: LLM Comparison
**AI Asks:** "Let's start with LLMs (Large Language Models). Test the same question with at least 2 different LLMs (like ChatGPT, Claude, Gemini, or Perplexity). Try both a simple question and a complex one. What differences do you notice in their responses, capabilities, and interaction styles?"

**Happy Path Response:**
"I tested 'What's the capital of France?' and 'Explain quantum computing for a business executive.' ChatGPT gave more conversational responses with examples, while Claude was more structured and precise. For the complex question, Claude provided better business context and analogies, while ChatGPT was more technical. I noticed Claude asks more clarifying questions, while ChatGPT tends to give comprehensive answers immediately."

**Expected AI Behavior:** Build on observations and move to image generation tools.

**Neutral Path Response:**
"They gave different answers but both were okay."

**Expected AI Behavior:** Probe for specifics: "What kind of differences did you notice? Was one more helpful for certain types of questions? Did you prefer one style over another?"

**Sad Path Response:**
"I couldn't tell the difference."

**Expected AI Behavior:** Provide guidance: "Try asking them the same specific question and compare side by side. For example, ask both 'How do I write a professional email?' and look at the format, length, and style of their responses."

</details>

---

## Day 4 Test Scenarios

<details>
<summary><strong>Task: "Blueprint Testing and Refinement" (Technical Assistant Mode)</strong></summary>

### Question 2: Response Quality Evaluation
**AI Asks:** "How was that response? Let me help you evaluate the quality critically. What worked well, what needs improvement, and how can we refine the prompt for better results?"

**Happy Path Response:**
"The response covered all the main points I asked for, but it was too generic and didn't include the specific local context I need for my disaster preparedness plan. It also used too much technical jargon that wouldn't work for a public-facing document. I think I need to add constraints about reading level and specify my city's particular climate risks."

**Expected AI Behavior:** Help develop specific refinement strategies and move to meta-prompting.

**Neutral Path Response:**
"It was okay but could be better."

**Expected AI Behavior:** Probe for specifics: "What specifically could be better? Was it too long, too short, missing information, or formatted poorly? Help me understand what didn't meet your needs."

**Sad Path Response:**
"I don't know if it's good or not."

**Expected AI Behavior:** Provide evaluation framework: "Let's break it down. Did it answer your question completely? Was it the right length? Did it use language appropriate for your audience? Was the format what you expected?"

### Question 3: Meta-Prompting Experiment
**AI Asks:** "Let's try meta-prompting - ask me to critique my own response and suggest improvements to the prompt. What new insights does this technique reveal about prompt refinement?"

**Happy Path Response:**
"When I asked you to critique your disaster plan response, you identified that it lacked specific local data, used inconsistent formatting, and didn't prioritize recommendations by urgency. You suggested I add constraints for data sources, specify output format, and request priority rankings. This meta-prompting revealed that AI can identify its own weaknesses and suggest specific prompt improvements I wouldn't have thought of."

**Expected AI Behavior:** Acknowledge successful meta-prompting and continue with blueprint testing.

**Neutral Path Response:**
"You said some things could be improved."

**Expected AI Behavior:** Probe for learning: "What specific improvements did I suggest? How were those suggestions different from what you might have thought of on your own?"

**Sad Path Response:**
"I don't understand what meta-prompting means."

**Expected AI Behavior:** Clarify and guide: "Meta-prompting means asking me to think about my own response. Try asking me 'What are the weaknesses in the response you just gave me?' or 'How could you improve that answer?' What happens when you try that?"

</details>

<details>
<summary><strong>Task: "Prompt Critique Workshop" (Coach Only Mode)</strong></summary>

### Question 3: Constructive Feedback Delivery
**AI Asks:** "Provide specific, constructive feedback focusing on: What worked well in their design? What could be clearer or more effective? What alternative approaches might they consider?"

**Happy Path Response:**
"Their nonprofit fundraising prompts had excellent structure and clear role definitions for the AI. The strength was breaking down the campaign into logical phases. However, the prompts could be more effective with specific constraints on reading level and more detailed examples of successful fundraising language. Alternative approaches might include testing different donor personas or adding emotional storytelling elements to the campaign copy requests."

**Expected AI Behavior:** Acknowledge quality feedback and move to reflection on received feedback.

**Neutral Path Response:**
"Their prompts were pretty good but could use some work."

**Expected AI Behavior:** Push for specifics: "What specifically was good about them? What kind of work do they need? Give me concrete examples of what you'd change or improve."

**Sad Path Response:**
"I don't know how to give feedback on prompts."

**Expected AI Behavior:** Provide framework: "Start with what you noticed. Did their prompts give clear instructions? Were they specific enough? Did the AI outputs match what they were trying to achieve? Pick one thing that worked well and one thing that could be improved."

</details>

## Day 5 Test Scenarios

<details>
<summary><strong>Task: "Convincing Grandma to Use AI" (Coach Only Mode)</strong></summary>

### Question 2: Simple AI Explanation
**AI Asks:** "How would YOU explain what AI is in simple, non-technical terms that your chosen person would understand and care about? Think about their daily life and interests."

**Happy Path Response:**
"I'd tell my grandmother that AI is like having a really smart helper that can read and write faster than any human. Just like she uses a calculator to help with math, AI helps with thinking tasks like writing letters, finding information, or organizing ideas. It's not magic - it's just a computer program that learned from reading millions of books and articles, so it can help her with everyday tasks like writing emails to family or finding recipes."

**Expected AI Behavior:** Acknowledge clear explanation and move to identifying specific benefits.

**Neutral Path Response:**
"AI is like a smart computer that helps people."

**Expected AI Behavior:** Push for more connection: "That's a start! But how would you make that meaningful to your specific person? What would they care about or relate to in their daily life?"

**Sad Path Response:**
"I don't know how to explain it without using technical words."

**Expected AI Behavior:** Provide analogies: "Think about tools they already use and trust. Do they use GPS for directions? A calculator for math? A search engine to find information? AI is similar to these - it's just a tool that helps with thinking and writing tasks."

### Question 5: Complete Presentation Structure
**AI Asks:** "Structure your complete 60-second presentation: How will you explain AI simply, present the three benefits, address their concerns, and provide clear getting-started steps? Practice your timing and delivery."

**Happy Path Response:**
"Grandma, you know how you spend time writing long emails to the family and sometimes struggle to find the right words? AI is like having a writing assistant that helps you express your thoughts clearly. It could help you write better emails to us grandkids, find new recipes based on what's in your fridge, and even help you organize your photo albums with descriptions. I know you worry about technology being too complicated, but this is as simple as typing a question and getting an answer - like asking a very knowledgeable friend. We could start by having you try it once a week to help write one email, and I'll be right there to help you. What do you think?"

**Expected AI Behavior:** Provide feedback on presentation effectiveness and conclude the task.

**Neutral Path Response:**
"AI can help you with writing and finding information. It's easy to use. You should try ChatGPT."

**Expected AI Behavior:** Coach for improvement: "You have the basic elements, but let's make it more personal and compelling. How can you connect to their specific situation? What would make them excited rather than just informed?"

**Sad Path Response:**
"I can't fit everything into 60 seconds."

**Expected AI Behavior:** Help prioritize: "Let's focus on the most important elements. What's the one benefit that would matter most to this person? What's their biggest concern? Build your presentation around those key points and practice saying it out loud."

</details>

---

## General Testing Guidelines

### Timing Expectations
- **Good responses:** AI should acknowledge and move forward within 1-2 exchanges
- **Neutral responses:** AI should probe 1-2 times before progressing
- **Poor responses:** AI should provide up to 3 supportive follow-ups before moving on

### Red Flags to Watch For
- AI accepts vague responses without probing
- AI gets stuck in endless probing loops
- AI moves forward too quickly from confused responses
- AI doesn't provide appropriate scaffolding for struggling builders
- AI fails to recognize when builders show basic understanding

### Success Indicators
- Natural conversation flow that feels supportive, not robotic
- Appropriate level of probing based on response quality
- Clear progression through all questions in sequence
- Proper recognition of task completion and deliverable requirements