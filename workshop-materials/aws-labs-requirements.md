# AWS Labs Requirements Document
## IT Infrastructure Workshop - University Apprenticeship Programme
### Revised Approach: AWS Console-Focused Practical Labs

---

## Executive Summary

This document outlines the requirements for a revised IT Infrastructure Workshop that focuses on hands-on AWS console skills through challenge-based learning. The workshop will use AWS Organizations for student account isolation and CloudFormation for infrastructure deployment, with intentional misconfigurations that students must troubleshoot and resolve.

---

## Workshop Overview

### Learning Philosophy
- **Challenge-Based Learning:** Students solve real-world AWS issues
- **Console-Focused:** Emphasis on AWS console navigation and skills
- **Practical Application:** Skills directly applicable in workplace
- **Progressive Difficulty:** Build from simple to complex challenges

### Target Audience
- **First-year university apprentices**
- **Basic computer literacy required**
- **No prior AWS experience necessary**
- **Web browser access required**

### Duration
- **Total:** 3 hours (workshop day)
- **Setup:** 4 days before (testing and preparation)
- **Theory:** 30 minutes (AWS concepts, console navigation)
- **Practical:** 2.5 hours (hands-on challenges and troubleshooting)

---

## Technical Architecture

### Infrastructure Design
```
Internet → Application Load Balancer → Auto Scaling Group → EC2 Instances
                                                              ↓
                                                         RDS MySQL
```

### 2-Tier Application Components
- **Web Tier:** Application Load Balancer + Auto Scaling Group + EC2
- **Database Tier:** RDS MySQL instance
- **Networking:** VPC with public/private subnets
- **Security:** Security Groups, NACLs, IAM roles
- **Monitoring:** CloudWatch dashboard and metrics

---

## AWS Organizations Setup

### Account Structure
```
Master Account (Instructor)
├── Organizational Unit: Workshop-2024
│   ├── Student Account 1 (Student-001)
│   ├── Student Account 2 (Student-002)
│   ├── Student Account 3 (Student-003)
│   └── ... (up to 8 students)
```

### Benefits of AWS Organizations Approach
- ✅ **Complete Isolation:** Each student has their own AWS account
- ✅ **Billing Separation:** Individual billing per student account
- ✅ **Security Isolation:** No cross-account access or visibility
- ✅ **Easy Cleanup:** Delete individual accounts after workshop
- ✅ **Cost Control:** Set budgets and alerts per account
- ✅ **Governance:** Use Service Control Policies for restrictions

### Account Creation Process
1. **Pre-Workshop Setup:**
   - Create AWS Organizations structure
   - Generate student accounts (automated script)
   - Set up billing alerts and budgets
   - Configure Service Control Policies
   - Generate temporary passwords

2. **Student Onboarding:**
   - Provide account credentials securely
   - Guide through initial AWS console login
   - Set up MFA (optional)
   - Verify account access and permissions

3. **Post-Workshop Cleanup:**
   - Automated account deletion
   - Final billing reconciliation
   - Resource cleanup verification

---

## Lab Challenges Design

### Challenge 1: NACL Misconfiguration
**Scenario:** Application is deployed but not accessible from internet
**Root Cause:** Network ACL blocking inbound traffic on port 80
**Learning Objectives:**
- Understand VPC networking layers
- Learn NACL vs Security Group differences
- Practice troubleshooting network connectivity
- Use AWS console to diagnose issues

**Implementation:**
- Deploy CloudFormation with overly restrictive NACL rules
- Block inbound HTTP traffic (port 80)
- Students must identify and fix the NACL rules

### Challenge 2: Security Group Misconfiguration
**Scenario:** Load balancer health checks failing
**Root Cause:** Security group rules blocking health check traffic
**Learning Objectives:**
- Understand Security Group rules and precedence
- Learn about load balancer health checks
- Practice security group troubleshooting
- Understand stateful vs stateless filtering

**Implementation:**
- Deploy with incorrect security group rules
- Block health check traffic from load balancer
- Students must identify and correct security group rules

### Challenge 3: IAM Permission Issues
**Scenario:** Application can't access required AWS services
**Root Cause:** EC2 instance role lacks necessary permissions
**Learning Objectives:**
- Understand IAM roles and policies
- Learn about EC2 instance profiles
- Practice IAM troubleshooting
- Understand least privilege principle

**Implementation:**
- Deploy with insufficient IAM permissions
- Application fails to access S3 or other services
- Students must update IAM policies

### Challenge 4: Load Balancer Configuration
**Scenario:** Load balancer targets unhealthy
**Root Cause:** Incorrect health check configuration
**Learning Objectives:**
- Understand load balancer health checks
- Learn target group configuration
- Practice load balancer troubleshooting
- Understand application health endpoints

**Implementation:**
- Deploy with wrong health check settings
- Health checks failing due to incorrect path/port
- Students must fix health check configuration

### Challenge 5: Blue-Green Deployment
**Scenario:** Demonstrate zero-downtime deployment
**Root Cause:** N/A - This is a demonstration challenge
**Learning Objectives:**
- Understand blue-green deployment strategy
- Learn ALB listener rules and target groups
- Practice traffic switching
- Understand rollback procedures

**Implementation:**
- Deploy version 1 (blue) with simple HTML page
- Deploy version 2 (green) with updated page
- Switch traffic between versions
- Demonstrate rollback capability

---

## CloudFormation Templates

### Template 1: Working 2-Tier Application
**Purpose:** Baseline working application for students to understand
**Components:**
- VPC with public/private subnets
- Internet Gateway and NAT Gateway
- Security Groups (web, app, db)
- Application Load Balancer
- Auto Scaling Group with Launch Template
- RDS MySQL instance
- CloudWatch dashboard

### Template 2: NACL Challenge
**Purpose:** Deploy application with NACL misconfiguration
**Issues:**
- NACL rules blocking inbound HTTP traffic
- Students must identify and fix rules

### Template 3: Security Group Challenge
**Purpose:** Deploy application with security group issues
**Issues:**
- Security group rules blocking health checks
- Students must troubleshoot and fix

### Template 4: IAM Challenge
**Purpose:** Deploy application with IAM permission issues
**Issues:**
- EC2 instance role lacks required permissions
- Students must update IAM policies

### Template 5: Load Balancer Challenge
**Purpose:** Deploy application with load balancer misconfiguration
**Issues:**
- Health check configuration problems
- Students must fix target group settings

### Template 6: Blue-Green Deployment
**Purpose:** Demonstrate deployment strategies
**Components:**
- Two separate target groups
- ALB listener rules for traffic switching
- Version indicators in web pages

---

## Student Experience Flow

### Phase 1: Environment Setup (15 minutes)
1. **Account Access:**
   - Receive AWS account credentials
   - Login to AWS console
   - Verify account permissions
   - Navigate AWS console interface

2. **Initial Deployment:**
   - Deploy working 2-tier application
   - Verify application functionality
   - Understand architecture components

### Phase 2: Challenge Resolution (2 hours)
1. **Challenge 1: NACL Issues (30 minutes)**
   - Identify application connectivity problems
   - Troubleshoot network configuration
   - Fix NACL rules
   - Verify resolution

2. **Challenge 2: Security Groups (30 minutes)**
   - Diagnose load balancer health issues
   - Review security group rules
   - Correct misconfigurations
   - Test application functionality

3. **Challenge 3: IAM Problems (30 minutes)**
   - Identify permission-related failures
   - Review IAM roles and policies
   - Update permissions
   - Verify service access

4. **Challenge 4: Load Balancer (30 minutes)**
   - Troubleshoot target group health
   - Review health check configuration
   - Fix configuration issues
   - Validate load balancer functionality

### Phase 3: Advanced Topics (45 minutes)
1. **Blue-Green Deployment (30 minutes)**
   - Deploy version 1 (blue)
   - Deploy version 2 (green)
   - Switch traffic between versions
   - Demonstrate rollback

2. **Monitoring and Validation (15 minutes)**
   - Review CloudWatch metrics
   - Check application logs
   - Validate monitoring setup

---

## Assessment and Evaluation

### Learning Outcomes Assessment
**Technical Skills:**
- [ ] Can navigate AWS console effectively
- [ ] Can deploy CloudFormation stacks
- [ ] Can troubleshoot network connectivity issues
- [ ] Can configure security groups and NACLs
- [ ] Can manage IAM roles and policies
- [ ] Can configure load balancer settings
- [ ] Can perform blue-green deployments

**Problem-Solving Skills:**
- [ ] Can systematically troubleshoot AWS issues
- [ ] Can identify root causes of problems
- [ ] Can implement appropriate solutions
- [ ] Can validate fixes and improvements

**Documentation Skills:**
- [ ] Can document troubleshooting process
- [ ] Can explain technical concepts clearly
- [ ] Can provide screenshots and evidence
- [ ] Can describe solutions and rationale

### Assessment Methods
1. **Challenge Completion:** Students must resolve all challenges
2. **Documentation:** Students document their troubleshooting process
3. **Screenshots:** Evidence of fixes and solutions
4. **Explanations:** Students explain root causes and solutions
5. **Demonstration:** Students demonstrate working solutions

---

## Cost Management

### Estimated Costs per Student
- **EC2 Instances:** $0.00 (t2.micro, free tier - 750 hours/month)
- **RDS Instance:** $0.00 (db.t3.micro, free tier - 750 hours/month)
- **Load Balancer:** $0.18 (ALB, 6 hours total)
- **Data Transfer:** $0.05 (minimal usage)
- **Total per Student:** $0.23 for 6 hours total

### Cost Control Measures
- **AWS Budgets:** Set $10 limit per student account
- **Service Control Policies:** Restrict expensive services
- **Automated Cleanup:** Delete resources after workshop
- **Monitoring:** Real-time cost tracking
- **Alerts:** Notify when approaching limits

### Total Workshop Cost
- **8 Students:** $1.84 total
- **Additional Overhead:** $0.76 (automation infrastructure)
- **Grand Total:** $2.60 for complete workshop

---

## Risk Assessment and Mitigation

### Technical Risks
**Risk:** CloudFormation template failures
**Mitigation:** Thorough testing before workshop, backup templates

**Risk:** Student account access issues
**Mitigation:** Pre-test account creation, have backup credentials

**Risk:** Cost overruns
**Mitigation:** Strict budgets, automated cleanup, monitoring

**Risk:** Challenge difficulty too high/low
**Mitigation:** Pilot testing with sample students, adjustable difficulty

### Operational Risks
**Risk:** Instructor technical issues
**Mitigation:** Comprehensive instructor training, backup support

**Risk:** Student onboarding delays
**Mitigation:** Pre-workshop setup, clear instructions

**Risk:** Resource cleanup failures
**Mitigation:** Automated scripts, manual verification process

---

## Deliverables Required

### 1. CloudFormation Templates
- [ ] Working 2-tier application template
- [ ] NACL challenge template
- [ ] Security group challenge template
- [ ] IAM challenge template
- [ ] Load balancer challenge template
- [ ] Blue-green deployment templates

### 2. Documentation
- [ ] AWS Organizations setup guide
- [ ] Student onboarding instructions
- [ ] Lab guide with step-by-step instructions
- [ ] Challenge descriptions and hints
- [ ] Answers section with solutions
- [ ] Troubleshooting reference guide

### 3. Automation Scripts
- [ ] Account creation automation
- [ ] Resource cleanup scripts
- [ ] Cost monitoring setup
- [ ] Health check validation

### 4. Training Materials
- [ ] Instructor preparation guide
- [ ] Student pre-workshop materials
- [ ] Presentation slides (AWS console focused)
- [ ] Demo scripts for challenges

---

## Implementation Timeline

### Phase 1: Preparation (2 weeks before)
- [ ] Set up AWS Organizations structure
- [ ] Create and test CloudFormation templates
- [ ] Develop lab guide and documentation
- [ ] Create student accounts
- [ ] Test all challenges and solutions

### Phase 2: Pilot Testing (1 week before)
- [ ] Test with 2-3 sample students
- [ ] Refine challenges and documentation
- [ ] Adjust difficulty levels
- [ ] Finalize instructor materials

### Phase 3: Workshop Delivery
- [ ] Student onboarding
- [ ] Challenge-based lab sessions
- [ ] Real-time support and guidance
- [ ] Assessment and feedback collection

### Phase 4: Cleanup and Follow-up
- [ ] Automated resource cleanup
- [ ] Final cost reconciliation
- [ ] Student feedback analysis
- [ ] Workshop improvement planning

---

## Success Metrics

### Student Engagement
- [ ] 90%+ completion rate for all challenges
- [ ] Average challenge completion time within expected range
- [ ] High student satisfaction scores (4.0+/5.0)
- [ ] Active participation in troubleshooting discussions

### Learning Outcomes
- [ ] Students can independently navigate AWS console
- [ ] Students can troubleshoot common AWS issues
- [ ] Students understand AWS service relationships
- [ ] Students can perform basic deployments

### Technical Performance
- [ ] All CloudFormation templates deploy successfully
- [ ] Challenges are solvable within time limits
- [ ] Cost targets met (under $30 per student)
- [ ] Cleanup completed successfully

---

## Conclusion

This revised approach provides a much more practical, hands-on learning experience that focuses on real AWS console skills. The challenge-based learning methodology will be more engaging for students and better prepare them for real-world scenarios they'll encounter in their careers.

**Key Benefits:**
- **Practical Skills:** Direct AWS console experience
- **Real Scenarios:** Common issues students will face
- **Cost Effective:** Isolated accounts with controlled costs
- **Scalable:** Can accommodate 20+ students
- **Engaging:** Challenge-based learning approach

**Next Steps:**
1. Approve this requirements document
2. Begin CloudFormation template development
3. Set up AWS Organizations structure
4. Create detailed lab guides and documentation
5. Conduct pilot testing with sample students

---

**Ready to build an amazing AWS-focused workshop! 🚀**
