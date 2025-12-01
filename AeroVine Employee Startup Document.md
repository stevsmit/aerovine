## **🚀 Phase 1: Establish Your Technical Foundation (Days 1-3)**

This phase focuses on setting up your computer and understanding the basic environment.

### **Step 1: Learn the Command Line (Terminal)**

Since you use a Mac, the primary way software developers interact with essential tools is through the **Terminal**. This is crucial, as you'll likely use it to manage code and connect to drones/servers.

* **Task A: Locate and Open Terminal:** Find the **Terminal** app (under Applications $\\rightarrow$ Utilities).  
* **Task B: Master Basic Commands:** Practice the most common Linux commands (often called "Bash" commands on Mac):  
  * ls (list files)  
  * cd (change directory)  
  * mkdir (make a new directory/folder)  
  * pwd (print working directory/show where you are)  
  * cat (view file contents)

### **Step 2: Install Essential Software**

You'll need a way to edit code and run development environments.

* **Task A: Install a Code Editor:** Download and install **VS Code (Visual Studio Code)**. It's the most popular, versatile, and beginner-friendly code editor.  
* **Task B: Install Python:** AI and drone software often heavily rely on **Python**. Your Mac has a version installed, but it’s best practice to use a tool like **Homebrew** (a package manager) to install a modern version.  
  * Install Homebrew (using a command from its website).  
  * Use Homebrew to install the latest Python 3: brew install python3

### **Step 3: Understand Version Control (Git)**

In a software company, nobody works alone on code. **Git** is the industry standard for tracking changes and collaborating. **GitHub** is a service that hosts Git repositories.

* **Task A: Set up Git:** Git is likely already installed on your Mac, but run the setup commands in Terminal to configure your username and email.  
* **Task B: Learn the Core Workflow:** Understand the three fundamental steps of Git:  
  * **Clone:** Get a copy of the company's code repository.  
  * **Commit:** Save your changes locally.  
  * **Push/Pull:** Send your changes to GitHub or retrieve others' changes.

---

## **🛰️ Phase 2: Grasp Drone & AI Concepts (Days 4-7)**

This phase focuses on the specific domains of your company, Acme.ai.

### **Step 4: Research Core AI/ML Concepts**

Since your company is "AI-first," understand the jargon the developers will be using.

* **Task A: Define Key Terms:** Research and write down simple definitions for:  
  * **Machine Learning (ML)**  
  * **Neural Networks**  
  * **Computer Vision (CV)** (This is critical for a drone's ability to "see" and navigate.)  
  * **Training Data**

### **Step 5: Understand Drone Software Architecture**

The software isn't just one program; it's a collection of systems.

* **Task A: The Three Systems:** Research the typical software split for a drone:  
  1. **Ground Control Station (GCS) Software:** What the pilot uses on a laptop (mission planning, telemetry).  
  2. **Flight Controller Firmware:** The real-time operating system on the drone that controls motors and sensors (e.g., PX4 or ArduPilot).  
  3. **Companion Computer (AI) Software:** A separate, powerful computer on the drone (like a Jetson Nano) that runs the complex AI/CV code.  
* **Task B: Focus on Communication:** Learn what a **telemetry link** is and how the Ground Station talks to the Flight Controller (often using protocols like **MAVLink**).

### **Step 6: Tackle Networking Basics**

Your fear of networking is manageable\! You just need to understand how the drone and your computer will talk to each other.

* **Task A: The Basics of IP:** Review the concept of an **IP Address** and a **Port**.  
* **Task B: Wireless Connection:** Understand that in a development environment, the drone's companion computer usually creates its own Wi-Fi network that your Mac connects to. You will use **SSH (Secure Shell)** to connect from your Mac's Terminal to the drone's computer and deploy the AI code.  
  * *Self-Training:* Practice an SSH command using a free online demo or a Raspberry Pi if you have one.

---

## **✅ Phase 3: Integrate and Contribute (Ongoing)**

Once your foundation is set, you can start doing useful work.

### **Step 7: Use the Issue Tracking System (Jira/Trello)**

The software department uses a system to organize tasks, bugs, and features.

* **Task A: Identify the Platform:** Find out if Acme.ai uses **Jira, Asana, Trello, or Linear**.  
* **Task B: Learn Statuses:** Understand the standard workflow: **To Do $\\rightarrow$ In Progress $\\rightarrow$ Review $\\rightarrow$ Done**.

### **Step 8: Focus on Documentation**

As a non-technical member of the software department, your greatest value will initially be in **clear communication and documentation**.

* **Task A: Document the Build/Deployment Process:** Work with an engineer to write out, step-by-step, how to take the latest AI code, compile it (if necessary), and transfer it onto the drone's companion computer. This is often the most confusing part for newcomers, and a clean document will save the team time.  
* **Task B: Write User Stories:** When a new feature is requested (e.g., "The drone should avoid birds"), write the **User Story** for the developers: "As a \[User Role\], I want \[Goal\], so that \[Reason/Benefit\]."

### **Step 9: Find a Mentor and Ask Smart Questions**

Don't suffer in silence. Your startup simulation is a learning experience.

* **Task A: Identify a Go-To Engineer:** Find one friendly, patient engineer and let them know you are trying to learn the tools.  
* **Task B: Ask Actionable Questions:** Instead of "What is Git?", ask: "**I'm trying to commit my documentation changes, but I'm getting an error about a conflict. Could you show me how to resolve a conflict?**" This shows you've tried and are ready to learn a specific skill.

By focusing on these practical steps—Terminal, VS Code, Git, and understanding the three core drone systems—you will quickly become an effective and valuable member of the Software department.