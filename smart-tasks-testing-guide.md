# Smart Tasks Testing Guide

## Overview
Smart Tasks are AI-powered learning experiences that guide builders through structured activities using conversational AI. This guide helps you test and validate the core functionality.

## What Are Smart Tasks?
Smart Tasks use our upgraded LLM infrastructure (via OpenRouter) to create adaptive, conversational learning experiences. The AI acts as a mentor, guiding builders through predefined question sequences while providing personalized support.

## Key Testing Areas

### 1. 🎯 Introduction Phase
**What to Look For:**
- Clear task introduction that explains the focus and goals
- If resources are linked, the AI should ask builders to review them first
- The AI should ask: "What are your key takeaways?" after resource review
- Task description should be presented clearly using the provided content

**Test Scenario:**
- Start a task with linked resources
- Verify the AI requests resource review before proceeding
- Check that the task description matches what's configured

### 2. 🔄 Question Sequence Flow
**Critical Behavior:**
- AI MUST use exact question language from the task configuration
- Questions should be asked in the specified order
- AI should NEVER skip or jump around questions
- When moving to next question, AI should say: "Let's move to question [X]: [EXACT QUESTION TEXT]"

**What to Test:**

- Verify exact question wording matches configuration
- Check that all questions are covered systematically

**Red Flags:**
- ❌ AI paraphrases or rephrases questions
- ❌ AI skips questions
- ❌ AI allows jumping ahead in sequence

### 3. 🤔 Response Quality Assessment
**The AI Should:**
- Analyze every builder response for thoroughness
- Recognize quality responses and move forward quickly
- Identify when responses need improvement

**Quality Indicators:**
- ✅ **Thorough Response**: Specific details, examples, addresses core question
- ❌ **Needs Work**: Vague answers, too short, lacks examples, shows confusion

**Test Different Response Types:**
- Give a detailed, thoughtful answer → AI should acknowledge and move on
- Give a vague answer like "AI is helpful" → AI should probe deeper
- Give a confused response → AI should provide scaffolding support

### 4. 🎯 Probing and Support
**When Builder Responses Need Work:**
The AI should ask clarifying questions to help builders think deeper.

**Expected Probing Patterns:**
- **Vague answers**: "How specifically does that work? Can you give me an example?"
- **Confused builders**: "Let's start smaller. What's one thing you do know about [topic]?"
- **Short answers**: "Tell me more about that. What makes you think so?"
- **Off-topic**: "Let's focus on our current question: [exact question]. How would you approach this?"

**Test Scenarios:**
- Give increasingly vague responses
- Act confused about the topic
- Provide very brief answers
- Go off-topic

**Important**: AI should stop probing after 2-3 follow-ups and move forward when builder shows basic understanding.

### 5. ✅ Task Completion Recognition
**The AI Should:**
- Work through ALL questions systematically
- Recognize when the task is complete
- If there's a deliverable, prompt the builder to submit it
- Provide clear completion confirmation

**Test Completion Flow:**
- Complete all questions in a task
- Verify AI recognizes completion
- Check if deliverable submission is prompted (when applicable)
- Ensure AI doesn't continue asking questions after completion

## Testing Checklist

### Pre-Test Setup
- [ ] Verify task has proper question sequence configured
- [ ] Check if resources are linked correctly
- [ ] Confirm deliverable requirements (if any)

### During Testing
- [ ] Introduction includes resource review request (if applicable)
- [ ] Questions use exact configured language
- [ ] Questions follow proper sequence
- [ ] AI probes appropriately for weak responses
- [ ] AI recognizes quality responses and progresses
- [ ] AI stays focused on current question

### Post-Completion
- [ ] All questions were covered
- [ ] Task completion was recognized
- [ ] Deliverable submission prompted (if applicable)
- [ ] Clear ending/transition provided

## Common Issues to Watch For

### ❌ Question Handling Problems
- AI rephrases questions instead of using exact text
- AI skips questions or allows jumping ahead
- AI gets stuck on one question too long

### ❌ Response Assessment Issues
- AI accepts vague responses without probing
- AI probes too aggressively on good responses
- AI doesn't recognize when to move forward

### ❌ Flow Problems
- Task doesn't have clear beginning or end
- AI continues asking questions after completion
- Deliverable requirements unclear or missing

## Success Criteria
A well-functioning Smart Task should feel like a natural conversation with a knowledgeable mentor who:
- Keeps you on track with the learning objectives
- Asks good follow-up questions when you need to think deeper
- Recognizes when you've grasped the concept and moves forward
- Guides you to successful task completion

## Reporting Issues
When testing, note:
- Specific question where issue occurred
- Builder response that triggered the problem
- Expected vs. actual AI behavior
- Task configuration details (if relevant)

This helps developers quickly identify and fix issues in the prompt engineering or task configuration.
---

## Daily Smart Task Reference

This section provides the expected conversation flows for each smart task to help testers compare actual AI behavior against intended design.

<details>
<summary><strong>Day 1 - Sunday, August 31, 2025</strong></summary>

#### Task: "Spaghetti and Marshmallow Challenge" (13:15-14:15)
**Type:** Conversation Task  
**AI Helper Mode:** Research Partner  
**Has Deliverable:** No deliverable required

**Expected Introduction:**
"Time to kick off with a team building activity! You'll compete to see who can construct the tallest tower out of spaghetti and marshmallows.

**Challenge Structure:**
• **First Build (10 minutes)**: Build without any guidance to establish a baseline
• **Research Phase (5 minutes)**: Individual research using a special tool
• **New Groups + Second Build (5 minutes)**: Apply your research with new teammates
• **Share & Measure**: Present approaches and measure towers

**Your Goal:** Learn effective problem-solving strategies while building community with your cohort!"

**Question Sequence (4 questions):**
1. "Your facilitator will assign you to groups. You have 10 minutes to build your first tower with no direction - just spaghetti and marshmallows. See how tall you can build a freestanding tower. How did your initial approach work?"
2. "Surprise! Now spend 5 minutes using your LLM of choice (ChatGPT, Claude, Gemini) to research building strategies independently. What specific prompts did you use to get helpful building advice? What strategies did you discover?"
3. "Your facilitator will assign new groups. Compare the strategies you each found and decide on one approach. What strategy did your new group choose and why?"
4. "You have 5 minutes to build a new tower using your research. How did your AI-informed approach compare to your first attempt? What did you learn about using AI for practical problem-solving?"

**Expected Conclusion:** "You've experienced your first AI-assisted problem solving! You've learned that AI can provide valuable research and strategies, but successful building still requires teamwork and hands-on experimentation."

</details>

<details>
<summary><strong>Day 2 - Monday, September 1, 2025</strong></summary>

#### Task: "AI Prompting Techniques Workshop" (10:30-11:30)
**Type:** Conversation Task  
**AI Helper Mode:** Technical Assistant  
**Has Deliverable:** Yes - Refined prompts with iteration analysis for three scenarios

**Expected Introduction:**
"Time to get better at prompting through real practice! You'll try out three everyday scenarios and learn to improve your prompts based on how well they work. This uses what you just learned from Greg Brockman's prompting tips."

**Question Sequence (4 questions):**
1. "Let's practice with your first scenario: You want a quick vegetarian dinner recipe using ingredients you have at home. Write your initial prompt for this task. What specific ingredients and constraints should you include?"
2. "Let me help you refine that recipe prompt. Look at the response quality - what worked well and what could be clearer? Try a refined version and explain what changes you made."
3. "Second scenario: You need to write a professional email declining a client meeting while maintaining a positive relationship. Context: A potential client wants to meet next week to discuss a project, but you're fully booked and can't take on new work right now. You want to decline politely while keeping the door open for future opportunities. Create your first prompt for this email, then improve it based on the response quality. What refinement techniques made it better?"
4. "Final scenario: You're writing an executive project report that needs to explain technical concepts without jargon. Context: You're reporting on a software project to company executives who aren't technical - you need to explain what was built, the challenges faced, and the business impact in terms they'll understand and care about. Try your initial prompt for this report, then iterate. What patterns are you noticing in effective prompt refinement across all three scenarios?"

**Expected Conclusion:** "You've developed strong skills for improving prompts through real practice. These abilities will make every AI conversation you have more effective and valuable!"

---

#### Task: "How AI is Shaping the Future" (11:30-12:30)
**Type:** Conversation Task  
**AI Helper Mode:** Research Partner  
**Has Deliverable:** Yes - AI impact research report and team pitch

**Expected Introduction:**
"Time to dive deep into AI's impact on industries! You'll work in teams of 4-6 to research a domain you're curious about, then create a comprehensive analysis and present your findings to other teams."

**Question Sequence (5 questions):**
1. "Form your team of 4-6 people. Which domain will your team research together? Choose from: government, education, healthcare, business, social media, entertainment, transportation, manufacturing, or another area that interests your group."
2. "I'm here to help you research AI's impact on your chosen domain. What are the three biggest ways AI is currently transforming your selected industry? Let's find specific examples and supporting data together."
3. "What credible research and real-world examples can we find to support each of these impacts? Let's gather concrete evidence including statistics, case studies, and expert opinions to strengthen your analysis."
4. "Based on all your research, does your team think AI's overall impact on this domain will be net positive or negative? Create a Google Doc with your findings: the three biggest impacts, supporting evidence, and your team's perspective with reasoning."
5. "Prepare a compelling 30-45 second pitch of your findings. What are the most important points to highlight to convince others about AI's impact on your domain?"

**Expected Conclusion:** "You've done solid research into how AI actually affects the real world and can now explain both the good and bad sides. This knowledge will help you make smart decisions about AI in the future!"

---

#### Task: "AI Job Adaptation Challenge" (14:30-15:45)
**Type:** Conversation Task  
**AI Helper Mode:** Coach Only  
**Has Deliverable:** Yes - Future-proof job description with AI integration strategy

**Expected Introduction:**
"Time to get creative about jobs in the future! You'll work with your team to redesign a job for when AI is everywhere, figuring out how AI can help people do their work better instead of replacing them."

**Question Sequence (5 questions):**
1. "Form a group of 4-6 people. What job would your team like to redesign for the AI era? This could be a future-proof version of a job someone has had before, or a completely new AI-integrated role."
2. "For your chosen job, what are the main tasks someone currently does? List 5-7 key responsibilities that define this role today."
3. "Looking at your task list, which of these could AI handle effectively, and which ones require uniquely human skills like creativity, empathy, or complex judgment? What new AI-collaboration skills would someone need?"
4. "Based on your analysis, create a compelling future-proof job description. What are the key responsibilities, required skills, and AI integration aspects? Make it something you'd actually want to apply for!"
5. "Create a Google Doc with your job description and prepare a 30-45 second pitch presenting this role to a potential future employer. What are the most compelling points to highlight about human-AI collaboration in this role?"

**Expected Conclusion:** "You've learned how AI can enhance people's work capabilities rather than replace them. This strategic thinking will be valuable as you plan your own career!"

</details>

<details>
<summary><strong>Day 3 - Tuesday, September 2, 2025</strong></summary>

#### Task: "Content Moderation and Fake News Workshop" (18:45-19:45)
**Type:** Conversation Task  
**AI Helper Mode:** Research Partner  
**Has Deliverable:** Yes - Content moderation research and fake news creation analysis

**Expected Introduction:**
"Time to explore something tricky about AI: it can both fight fake news and create it! You'll research how content moderation works, try fact-checking some real claims, and see how easy it is for AI to make convincing fake stuff. The goal is learning to think critically about what you see online."

**Question Sequence (4 questions):**
1. "I'm here to help you research AI's role in content moderation. What are you curious about regarding how AI systems detect and manage harmful content at scale? Let's explore how these systems work and their limitations together."
2. "Let's practice fact-checking together. Find 3 social media claims (aim for 1 that seems true, 1 uncertain, and 1 suspicious) and verify each one using reliable sources. What fact-checking strategies work best, and what challenges did you encounter?"
3. "Let's research what makes content qualify as 'fake news' together. What are the key characteristics of misleading information? How do people typically get fooled by false content?"
4. "Now let's experiment responsibly with AI's content creation capabilities. Ask me to help you create a convincing but fake headline about a current event (we'll clearly label it as fake). What techniques make AI-generated content so persuasive, and how could you spot similar fake content in the future?"

**Expected Conclusion:** "You now understand that AI can both fight fake news and create it really well. Knowing both sides will help you use AI responsibly and spot fake content when you see it online."

---

#### Task: "AI Tool Landscape Explorer" (20:00-21:45)
**Type:** Conversation Task  
**AI Helper Mode:** Research Partner  
**Has Deliverable:** Yes - AI tool landscape evaluation and recommendations

**Expected Introduction:**
"Time to explore the diverse AI tools available! You'll test different types of tools - text AIs, image generators, coding assistants, and audio tools - to understand their capabilities and learn how to select the right tool for different projects."

**Question Sequence (5 questions):**
1. "Let's start with LLMs (Large Language Models). Test the same question with at least 2 different LLMs (like ChatGPT, Claude, Gemini, or Perplexity). Try both a simple question and a complex one. What differences do you notice in their responses, capabilities, and interaction styles?"
2. "Now let's explore image generation tools. Try the same creative prompt with 2 different image generators (like DALL-E, Midjourney, Leonardo, or Stable Diffusion). What are the strengths and limitations you notice? Which would you choose for different types of projects?"
3. "Let's test code assistance tools. Try the same small coding challenge with 2 different code assistants (like GitHub Copilot, Cursor, Replit AI, or CodeWhisperer). How do they compare for code generation, explanation, and debugging help?"
4. "Finally, explore audio/speech tools if available. Test transcription, voice generation, or audio editing capabilities with tools like Otter, ElevenLabs, or others. What potential applications do you see for audio AI tools?"
5. "Based on your hands-on testing across all categories, create a tool evaluation report. Which tools excelled in what areas? What criteria would you use to select the right tool for different types of projects?"

**Expected Conclusion:** "You now know what AI tools are out there and how to pick the right one for different jobs. This knowledge will help you choose the best AI tool for whatever you want to build!"

</details>

<details>
<summary><strong>Day 4 - Wednesday, September 3, 2025</strong></summary>

#### Task: "Blueprint Testing and Refinement" (19:30-20:30)
**Type:** Conversation Task  
**AI Helper Mode:** Technical Assistant  
**Has Deliverable:** Yes - Tested and refined prompt blueprint with outputs and learning log

**Expected Introduction:**
"Time to put your prompt plan into action! You'll test your step-by-step approach with real AI, learn to improve prompts based on how well they work, and try advanced tricks like asking AI to critique itself."

**Question Sequence (5 questions):**
1. "Let me help you execute your prompt blueprint systematically. Start with your first subtask - what prompt will you test first, and what response are you hoping to achieve?"
2. "How was that response? Let me help you evaluate the quality critically. What worked well, what needs improvement, and how can we refine the prompt for better results?"
3. "Let's try meta-prompting - ask me to critique my own response and suggest improvements to the prompt. What new insights does this technique reveal about prompt refinement?"
4. "Continue testing the rest of your blueprint subtasks. For each one, let me help you iterate and improve. What patterns are you noticing about what makes prompts more effective?"
5. "Create a Google Doc documenting your complete prompt evolution process: original blueprints, final refined prompts, AI outputs, and your key learnings about effective refinement techniques."

**Expected Conclusion:** "You've gotten really good at the full process: planning prompts, testing them, and making them better. These skills will help you handle any tricky AI task by breaking it down and improving it step by step!"

---

#### Task: "Prompt Critique Workshop" (20:45-21:15)
**Type:** Conversation Task  
**AI Helper Mode:** Coach Only  
**Has Deliverable:** Yes - Peer feedback analysis and prompt critique insights

**Expected Introduction:**
"Time to help each other get better at prompting! You'll swap your prompt plans and results with other teams, then give helpful feedback to help everyone improve."

**Question Sequence (4 questions):**
1. "Exchange your prompt designs and outputs with another team. Review their work systematically - analyze their prompt structure, evaluate output quality, and identify both strengths and areas for improvement."
2. "Test their prompts with tricky inputs or edge cases to assess robustness. What happens when you try misleading or challenging inputs with their prompt design?"
3. "Provide specific, constructive feedback focusing on: What worked well in their design? What could be clearer or more effective? What alternative approaches might they consider?"
4. "Based on the feedback you received from others about your own prompts, what key insights will you apply to future prompt design? What patterns did you notice across different teams' approaches?"

**Expected Conclusion:** "You've gotten better at prompting by reviewing each other's work and giving helpful feedback. Seeing how different people tackle the same challenge has given you more ideas for your own prompting!"

</details>

<details>
<summary><strong>Day 5 - Thursday, September 4, 2025</strong></summary>

#### Task: "Convincing Grandma to Use AI" (18:45-19:15)
**Type:** Conversation Task  
**AI Helper Mode:** Coach Only  
**Has Deliverable:** Yes - 60-second AI advocacy presentation script

**Expected Introduction:**
"Time to put everything you've learned together! You'll create a 60-second presentation to convince someone you care about to start using AI. This tests whether you can explain complicated stuff simply and show why it's actually useful."

**Question Sequence (5 questions):**
1. "Who specifically would you like to convince to use AI? Choose someone like a grandparent, boss, spouse, or friend who isn't currently using AI to its full potential. What's their relationship with technology like?"
2. "How would YOU explain what AI is in simple, non-technical terms that your chosen person would understand and care about? Think about their daily life and interests."
3. "Based on what you know about this person, what are three specific, practical ways AI could make their life easier or better? Focus on real benefits they would actually value."
4. "What concerns or fears might they have about AI technology, and how would YOU address these concerns in a reassuring, honest way?"
5. "Structure your complete 60-second presentation: How will you explain AI simply, present the three benefits, address their concerns, and provide clear getting-started steps? Practice your timing and delivery."

**Expected Conclusion:** "You've taken complicated AI stuff and made it simple and convincing! Being able to explain technical things in ways people actually care about will help you in any job involving technology."

</details>

## Testing Notes

### Smart Task vs Basic Task Identification
- **Conversation Tasks:** Use the standard question sequence format with AI helper modes
- **Basic Tasks:** Use traditional prompts or smart_prompt systems
- **Smart Tasks:** Only the conversation tasks should be tested using this guide's conversation flow expectations

### Key Testing Focus Areas
- Question sequence adherence (exact language)
- Proper introduction delivery
- Appropriate probing when responses need work
- Recognition of task completion
- Deliverable submission prompts (when applicable)
- AI helper mode behavior consistency