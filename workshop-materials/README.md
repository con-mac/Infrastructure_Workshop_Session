# AWS Infrastructure Workshop - Complete Package
## Challenge-Based Learning for University Apprentices

---

## 🎯 Workshop Overview

This comprehensive AWS Infrastructure Workshop has been completely revised to focus on **hands-on AWS console skills** through **challenge-based learning**. Students work through realistic troubleshooting scenarios that they'll encounter in professional cloud engineering roles.

### Key Features
- ✅ **AWS Console-Focused:** Real AWS skills students will use daily
- ✅ **Challenge-Based Learning:** Solve realistic problems, not just follow tutorials
- ✅ **Automated Account Creation:** Students self-register with email addresses
- ✅ **Complete Isolation:** Each student gets their own AWS account
- ✅ **Professional Experience:** Real AWS accounts, not sandboxes
- ✅ **Cost Controlled:** Individual budgets and automated cleanup

---

## 📁 Package Contents

### 1. CloudFormation Templates (`/cloudformation/`)
- **`working-2-tier-app.yaml`** - Baseline working application
- **`nacl-challenge.yaml`** - Network ACL misconfiguration challenge
- **`security-group-challenge.yaml`** - Security group health check issues
- **`iam-challenge.yaml`** - IAM permission problems
- **`load-balancer-challenge.yaml`** - Load balancer configuration issues
- **`blue-green-deployment.yaml`** - Blue-green deployment demonstration

### 2. Lab Guide (`lab-guide.md`)
- **Step-by-step instructions** for all challenges
- **Troubleshooting methodologies** and best practices
- **AWS console navigation** guidance
- **Learning objectives** and outcomes
- **Time estimates** and progress tracking

### 3. Answers Section (`answers-section.md`)
- **Complete solutions** to all challenges
- **Technical explanations** and root cause analysis
- **Instructor notes** and teaching tips
- **Common troubleshooting** scenarios
- **Best practices** summary

### 4. AWS Organizations Setup (`aws-organizations-setup.md`)
- **Complete setup guide** for automated account creation
- **AWS Organizations** configuration
- **IAM Identity Center** setup
- **Cost management** and monitoring
- **Security considerations** and best practices

### 5. Automation System (`/automation/`)
- **`student-registration.html`** - Professional registration website
- **`lambda-account-creation.py`** - Automated account creation
- **`instructor-dashboard.html`** - Workshop management dashboard

### 6. Requirements Document (`aws-labs-requirements.md`)
- **Complete specifications** for the revised workshop
- **Technical architecture** and implementation details
- **Cost analysis** and management strategy
- **Risk assessment** and mitigation

---

## 🚀 Quick Start Guide

### For Instructors

#### 1. Pre-Workshop Setup (2 weeks before)
```bash
# 1. Set up AWS Organizations
- Enable AWS Organizations in your account
- Create workshop OU structure
- Configure IAM Identity Center

# 2. Deploy automation infrastructure
- Deploy CloudFormation template for automation
- Set up Lambda functions and API Gateway
- Configure SES for email notifications

# 3. Test all challenges
- Deploy each CloudFormation template
- Verify issues exist and solutions work
- Test student registration process
```

#### 2. Workshop Day Setup (1 hour before)
```bash
# 1. Deploy registration website
- Upload student-registration.html to S3
- Configure API Gateway endpoints
- Test registration flow

# 2. Prepare instructor dashboard
- Access instructor dashboard
- Verify all student accounts
- Check cost monitoring setup
```

#### 3. During Workshop
```bash
# 1. Student onboarding (15 minutes)
- Students register using email addresses
- Automated account creation
- Email delivery of access details

# 2. Challenge-based learning (3 hours)
- Students work through 5 challenges
- Instructor provides guidance and hints
- Real-time troubleshooting support

# 3. Cleanup (10 minutes)
- Automated resource cleanup
- Account deletion
- Cost reconciliation
```

### For Students

#### 1. Registration
1. **Visit registration website** (provided by instructor)
2. **Enter university email** and name
3. **Receive AWS account details** via email
4. **Access dedicated AWS account**

#### 2. Workshop Participation
1. **Deploy working application** to understand baseline
2. **Work through 5 challenges** systematically
3. **Troubleshoot and fix issues** with instructor guidance
4. **Document solutions** and learning outcomes

---

## 🎓 Learning Outcomes

### Technical Skills
- **AWS Console Navigation:** Find and use AWS services effectively
- **CloudFormation Deployment:** Deploy and manage infrastructure as code
- **Troubleshooting Methodology:** Systematic approach to problem-solving
- **Service Configuration:** Understand and fix AWS service settings
- **Architecture Understanding:** How AWS services work together

### Problem-Solving Skills
- **Root Cause Analysis:** Identify actual problems, not just symptoms
- **Critical Thinking:** Logical reasoning through complex issues
- **Persistence:** Work through challenges systematically
- **Documentation:** Record and explain troubleshooting process

### Professional Skills
- **Communication:** Explain technical concepts clearly
- **Collaboration:** Work effectively with others
- **Time Management:** Complete tasks within deadlines
- **Continuous Learning:** Seek knowledge and improvement

---

## 💰 Cost Management

### Estimated Costs (20 Students, 1 Day)
- **Student AWS Accounts:** $360-560 total
- **Automation Infrastructure:** $0.76 total
- **Grand Total:** $360-561

### Cost Control Features
- **Individual Budgets:** $50 limit per student account
- **Service Control Policies:** Restrict expensive services
- **Automated Cleanup:** Delete resources after workshop
- **Real-time Monitoring:** Track costs and usage
- **Budget Alerts:** Notify when approaching limits

---

## 🔧 Technical Architecture

### Student Account Structure
```
Master Account (Instructor)
├── AWS Organizations
├── IAM Identity Center (SSO)
├── Workshop OU
│   ├── Student Account 1
│   ├── Student Account 2
│   └── ... (up to 20 students)
```

### Challenge Architecture
```
Internet → Application Load Balancer → Auto Scaling Group → EC2 Instances
                                                              ↓
                                                         RDS MySQL
```

### Automation Flow
```
Email Registration → API Gateway → Lambda → Organizations → IAM Identity Center → Email
```

---

## 🎯 Challenge Overview

### Challenge 1: NACL Misconfiguration
- **Issue:** Network ACL blocks inbound HTTP traffic
- **Learning:** NACL vs Security Group differences
- **Solution:** Remove restrictive NACL rules

### Challenge 2: Security Group Issues
- **Issue:** ALB health checks failing
- **Learning:** Load balancer health check process
- **Solution:** Allow ALB security group access

### Challenge 3: IAM Permission Problems
- **Issue:** EC2 instance lacks service permissions
- **Learning:** IAM roles and policies
- **Solution:** Add required managed and custom policies

### Challenge 4: Load Balancer Configuration
- **Issue:** Health check port mismatch
- **Learning:** Health check configuration
- **Solution:** Fix target group health check port

### Challenge 5: Blue-Green Deployment
- **Issue:** Demonstrate zero-downtime deployment
- **Learning:** Deployment strategies
- **Solution:** Traffic switching between versions

---

## 🛡️ Security Features

### Account Isolation
- **Complete Separation:** Each student has their own AWS account
- **No Cross-Account Access:** Students cannot see other students' resources
- **Billing Isolation:** Individual billing per student account
- **Resource Tagging:** All resources tagged for cost tracking

### Access Control
- **IAM Identity Center:** Centralised user management
- **Temporary Passwords:** Secure password generation
- **Time-Limited Access:** Accounts automatically cleaned up
- **Service Restrictions:** SCPs limit expensive services

---

## 📊 Monitoring and Management

### Instructor Dashboard
- **Real-time Monitoring:** Student progress and account status
- **Cost Tracking:** Individual and total workshop costs
- **Account Management:** Create, view, and delete student accounts
- **Automated Cleanup:** One-click workshop cleanup

### Student Experience
- **Self-Registration:** Simple email-based registration
- **Automated Setup:** Account creation and configuration
- **Email Notifications:** Welcome emails with access details
- **Progress Tracking:** Challenge completion status

---

## 🔄 Workshop Flow

### Phase 1: Setup (15 minutes)
1. **Student Registration:** Email-based account creation
2. **Account Access:** Login and initial setup
3. **Baseline Deployment:** Working application deployment

### Phase 2: Challenges (3 hours)
1. **NACL Challenge:** Network troubleshooting (30 minutes)
2. **Security Group Challenge:** Load balancer issues (30 minutes)
3. **IAM Challenge:** Permission problems (30 minutes)
4. **Load Balancer Challenge:** Health check configuration (30 minutes)
5. **Blue-Green Deployment:** Deployment strategies (45 minutes)

### Phase 3: Cleanup (10 minutes)
1. **Resource Cleanup:** Delete all workshop resources
2. **Account Deletion:** Remove student accounts
3. **Cost Reconciliation:** Final cost reporting

---

## 🎉 Success Metrics

### Student Engagement
- **90%+ Completion Rate:** All challenges completed
- **High Satisfaction:** 4.0+/5.0 student ratings
- **Active Participation:** Engaged troubleshooting discussions
- **Learning Outcomes:** Demonstrated AWS skills

### Technical Performance
- **Template Success:** All CloudFormation templates deploy correctly
- **Challenge Solvability:** Issues resolved within time limits
- **Cost Targets:** Under $30 per student
- **Cleanup Success:** All resources properly cleaned up

---

## 🚀 Next Steps

### For Instructors
1. **Review all materials** and test the setup
2. **Customise content** for your specific needs
3. **Set up AWS Organizations** and automation
4. **Conduct pilot testing** with sample students
5. **Deliver amazing workshop!** 🎓

### For Students
1. **Complete the workshop** and all challenges
2. **Explore additional AWS services** beyond the workshop
3. **Practice with personal projects** using AWS
4. **Consider AWS certification** paths
5. **Apply skills in professional roles** 🚀

---

## 📞 Support and Resources

### Documentation
- **Lab Guide:** Complete step-by-step instructions
- **Answers Section:** Solutions and explanations
- **Setup Guide:** AWS Organizations configuration
- **Requirements:** Complete specifications

### Troubleshooting
- **Common Issues:** Solutions to frequent problems
- **Best Practices:** Security and operational guidelines
- **Cost Management:** Budget and monitoring setup
- **Instructor Tips:** Teaching and support guidance

---

## 🎯 Conclusion

This revised AWS Infrastructure Workshop provides a **professional, hands-on learning experience** that directly prepares students for real-world cloud engineering roles. The challenge-based approach, automated account creation, and comprehensive materials ensure both instructors and students have an exceptional workshop experience.

**Key Benefits:**
- **Real AWS Skills:** Console navigation and troubleshooting
- **Professional Experience:** Dedicated AWS accounts
- **Scalable Solution:** Automated account management
- **Cost Effective:** Controlled spending and cleanup
- **Engaging Learning:** Challenge-based methodology

**Ready to deliver an amazing AWS workshop experience! 🚀**

---

*For questions or support, refer to the detailed documentation in each section or contact the workshop team.*