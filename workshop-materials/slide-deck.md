# Cloud Infrastructure Fundamentals - Slide Deck
## From On-Premises to AWS

**Target Audience:** First-year university students with little to no prior cloud experience  
**Duration:** 90-100 minutes  
**Focus Areas:** On-premises vs Cloud, Shared Responsibility, Networking, Compute, Automation, Monitoring  

---

# **Slide 1: Title Slide**

## **Cloud Infrastructure Fundamentals**
### **From On-Premises to AWS**

**Instructor:** [Your Name]  
**Workshop:** Apprentice Infrastructure Workshop  
**Date:** [Date]

---

**Instructor Notes:**
- Welcome students and set expectations
- Explain this is a hands-on workshop with both theory and practical labs
- Emphasise that no prior cloud experience is required
- Mention we'll start broad and focus down to AWS specifics
- **Timing:** 2-3 minutes

---

# **Slide 2: Learning Objectives**

## **By the end of this workshop, you will understand:**

• **On-premises vs Cloud computing** - pros and cons  
• **Public cloud providers** - AWS, Azure, GCP  
• **AWS core services** - networking, compute, storage  
• **Shared responsibility model** - who does what  
• **Automation and monitoring** - modern cloud practices  
• **Hands-on labs** - networking, RBAC, and compute challenges  

---

**Instructor Notes:**
- Read through each objective clearly
- Explain that we'll cover theory first, then apply it in labs
- Mention the three key lab focus areas: Networking, RBAC, Compute
- Ask if anyone has cloud experience to gauge the room
- **Timing:** 3-4 minutes

---

# **Slide 3: On-Premises vs Cloud Computing**

## **Traditional On-Premises Infrastructure**

**What is it?**
- Servers, storage, and networking equipment in your own data centre
- You own and manage everything physically
- Like having your own power plant vs using the grid

**Key Characteristics:**
- Physical hardware on-site
- Full control and responsibility
- Upfront capital investment
- Limited by physical space and power

---

**Instructor Notes:**
- Use the power plant analogy - everyone understands electricity
- Ask students to think of their university's computer labs
- Explain that most companies used to work this way
- **Timing:** 4-5 minutes

---

# **Slide 4: On-Premises: Pros and Cons**

## **Advantages:**
• **Full Control** - Complete ownership of hardware and software  
• **Data Sovereignty** - Data never leaves your premises  
• **Predictable Costs** - Known upfront investment  
• **Customisation** - Can modify hardware/software as needed  

## **Disadvantages:**
• **High Upfront Costs** - Servers, networking, cooling, power  
• **Maintenance Burden** - Updates, patches, hardware failures  
• **Limited Scalability** - Constrained by physical resources  
• **Expertise Required** - Need skilled IT staff  

---

**Instructor Notes:**
- Use examples: "Imagine buying a car vs using Uber"
- Ask students to think about their mobile phone - do they want to maintain the cell towers?
- Emphasise the maintenance burden - 24/7 monitoring, updates, security patches
- **Timing:** 5-6 minutes

---

# **Slide 5: Cloud Computing: Pros and Cons**

## **Advantages:**
• **Pay-as-you-go** - Only pay for what you use  
• **Scalability** - Scale up/down instantly  
• **No Maintenance** - Provider handles hardware, updates  
• **Global Reach** - Deploy anywhere in the world  
• **Latest Technology** - Access to newest hardware/software  

## **Disadvantages:**
• **Ongoing Costs** - Monthly bills can add up  
• **Internet Dependency** - Need reliable internet connection  
• **Less Control** - Dependent on provider's decisions  
• **Data Location** - Data stored in provider's data centres  

---

**Instructor Notes:**
- Use Netflix as an example - they moved from DVDs to streaming
- Explain "pay-as-you-go" with examples: like electricity bill
- Address security concerns - "Is your data safe in the cloud?"
- **Timing:** 5-6 minutes

---

# **Slide 6: Public Cloud Providers**

## **The Big Three:**

### **Amazon Web Services (AWS)**
- Market leader (33% market share)
- Comprehensive service portfolio
- Strong enterprise adoption

### **Microsoft Azure**
- Strong integration with Microsoft products
- Growing rapidly
- Good for hybrid cloud scenarios

### **Google Cloud Platform (GCP)**
- Strong in AI/ML and data analytics
- Competitive pricing
- Growing market presence

---

**Instructor Notes:**
- Show market share data if available
- Explain that all three are viable options
- Mention that we'll focus on AWS for this workshop
- Ask if students have heard of any of these before
- **Timing:** 4-5 minutes

---

# **Slide 7: Why Focus on AWS?**

## **Why AWS for This Workshop:**

• **Market Leader** - Most widely adopted cloud platform  
• **Comprehensive Services** - Everything you need in one place  
• **Excellent Documentation** - Great learning resources  
• **Free Tier** - Perfect for learning and experimentation  
• **Industry Standard** - Skills transfer to other clouds  
• **Real-world Relevance** - Used by Netflix, Airbnb, Spotify  

---

**Instructor Notes:**
- Mention that AWS skills are highly marketable
- Explain the AWS Free Tier - 12 months free for many services
- Use real-world examples students know: Netflix, Spotify
- **Timing:** 3-4 minutes

---

# **Slide 8: Shared Responsibility Model**

## **Who is Responsible for What?**

### **AWS is Responsible For:**
• **Infrastructure** - Data centres, servers, networking  
• **Platform** - Operating systems, runtimes  
• **Service** - AWS services availability and security  

### **You are Responsible For:**
• **Data** - What data you store and how you protect it  
• **Applications** - Your code and how you configure it  
• **Access Control** - Who can access your resources  
• **Compliance** - Meeting regulatory requirements  

---

**Instructor Notes:**
- Use the "landlord vs tenant" analogy
- Emphasise that security is shared - AWS secures the platform, you secure your data
- This is crucial for understanding cloud security
- **Timing:** 6-7 minutes

---

# **Slide 9: Network Fundamentals**

## **Virtual Private Cloud (VPC)**

**Think of it as:** Your own private neighbourhood in the cloud

### **Key Components:**
• **Subnets** - Public (internet-facing) vs Private (internal only)  
• **Internet Gateway** - Door to the internet  
• **Route Tables** - Traffic direction rules  
• **CIDR Blocks** - Address ranges (like postal codes)  
• **Security Groups** - Firewall rules for instances  
• **NACLs** - Network-level firewall rules  

---

**Instructor Notes:**
- Use the neighbourhood analogy extensively
- Explain public vs private subnets with examples
- CIDR blocks are like postal codes - they define address ranges
- Security Groups are like building security - they control access
- **Timing:** 8-10 minutes

---

# **Slide 10: Compute Services**

## **Virtual Machines (EC2)**

**What are they?** Virtual computers in the cloud

### **Key Features:**
• **Multiple Sizes** - From small to massive instances  
• **Operating Systems** - Windows, Linux, macOS  
• **Auto Scaling** - Automatically adjust capacity  
• **Load Balancing** - Distribute traffic across multiple instances  

### **Use Cases:**
• Web servers, databases, development environments  
• Any application that needs a full operating system  

---

**Instructor Notes:**
- Compare to renting a computer vs buying one
- Explain auto scaling with traffic examples
- Load balancing like having multiple cashiers at a store
- **Timing:** 6-7 minutes

---

# **Slide 11: Containers and Storage**

## **Containers (ECS/EKS)**
• **Lightweight** - Share the host OS  
• **Portable** - Run anywhere  
• **Efficient** - Use fewer resources than VMs  

## **Storage Options:**

### **S3 (Simple Storage Service)**
- Object storage for files, images, backups
- Virtually unlimited capacity

### **EBS (Elastic Block Store)**
- Block storage for EC2 instances
- Like a hard drive for your virtual machine

### **EFS (Elastic File System)**
- Shared file storage
- Multiple instances can access the same files

---

**Instructor Notes:**
- Containers are like shipping containers - standardised and portable
- Use examples: S3 for photos, EBS for databases, EFS for shared documents
- **Timing:** 6-7 minutes

---

# **Slide 12: Automation**

## **Serverless Computing (Lambda)**

**What is it?** Run code without managing servers

### **Benefits:**
• **No Server Management** - AWS handles everything  
• **Pay per Execution** - Only pay when code runs  
• **Automatic Scaling** - Handles any number of requests  

## **Infrastructure as Code (CloudFormation)**

**What is it?** Define your infrastructure in code

### **Benefits:**
• **Version Control** - Track changes over time  
• **Reproducible** - Deploy identical environments  
• **Automated** - No manual configuration  

---

**Instructor Notes:**
- Lambda is like having a personal assistant who only works when you need them
- CloudFormation is like having a recipe for your infrastructure
- Emphasise the "event-driven" nature - things happen automatically
- **Timing:** 7-8 minutes

---

# **Slide 13: Monitoring and Observability**

## **CloudWatch**

**What is it?** AWS's monitoring and observability service

### **Key Features:**
• **Metrics** - CPU usage, memory, disk space  
• **Logs** - Application and system logs  
• **Alarms** - Notifications when things go wrong  
• **Dashboards** - Visual representation of your systems  

### **Why It Matters:**
• **Proactive Monitoring** - Catch issues before they become problems  
• **Performance Optimisation** - Identify bottlenecks  
• **Cost Management** - Track spending and usage  

---

**Instructor Notes:**
- Compare to a car's dashboard - you need to see what's happening
- Explain that monitoring helps with troubleshooting (important for labs)
- Use examples: "What if your website is slow?" - CloudWatch helps find the cause
- **Timing:** 6-7 minutes

---

# **Slide 14: Key Takeaways**

## **What We've Learned:**

• **Cloud vs On-Premises** - Each has its place  
• **AWS Services** - Comprehensive platform for all needs  
• **Shared Responsibility** - Security is a partnership  
• **Networking** - VPCs, subnets, security groups  
• **Compute** - VMs, containers, serverless  
• **Automation** - Infrastructure as code, event-driven  
• **Monitoring** - Proactive problem detection  

## **Next Steps:**
Ready for hands-on labs focusing on **Networking**, **RBAC**, and **Compute**!

---

**Instructor Notes:**
- Summarise key concepts clearly
- Build excitement for the labs
- Mention that labs will reinforce these concepts
- Ask for questions before moving to labs
- **Timing:** 5-6 minutes

---

# **Slide 15: Lab Preview**

## **What You'll Build Today:**

### **Lab 1: Networking Fundamentals**
- Create VPCs and subnets
- Configure security groups
- Set up internet gateways

### **Lab 2: Identity and Access Management (RBAC)**
- Create IAM users and roles
- Set up permissions and policies
- Understand least privilege principle

### **Lab 3: Compute and Storage**
- Launch EC2 instances
- Configure storage options
- Implement auto-scaling

---

**Instructor Notes:**
- Explain that labs build on each other
- Emphasise that mistakes are learning opportunities
- Mention that you'll be available for help
- Set expectations for lab completion time
- **Timing:** 4-5 minutes

---

**Total Presentation Time: Approximately 90-100 minutes**

## **Additional Instructor Resources:**

### **Common Student Questions:**
- "Is cloud more expensive than on-premises?" - Depends on usage patterns
- "Is my data safe in the cloud?" - Shared responsibility model
- "Can I use multiple cloud providers?" - Yes, multi-cloud strategies exist
- "What if AWS goes down?" - Multiple availability zones, redundancy

### **Visual Aids Suggestions:**
- Draw VPC diagrams on whiteboard
- Use building/neighbourhood analogies for networking
- Show real AWS console screenshots
- Use traffic flow diagrams for load balancing

### **Engagement Tips:**
- Ask students about their own technology use (Netflix, Spotify)
- Use "raise your hand if..." questions
- Encourage questions throughout
- Relate concepts to familiar technology (mobile phones, streaming services)
