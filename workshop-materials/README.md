# IT Infrastructure Workshop - Complete Package
## University Apprenticeship Programme
### Friday 3rd October, 12:00–16:30

---

## Workshop Overview

This comprehensive workshop package provides everything needed to deliver a 4.5-hour IT Infrastructure workshop for first-year university apprentices. The workshop combines theory and practical hands-on labs to teach modern infrastructure concepts using cloud platforms and Infrastructure as Code.

### Target Audience
- **First-year university apprentices**
- **Basic command line knowledge required**
- **No prior cloud experience necessary**
- **Web browser access required**

### Learning Objectives
By the end of this workshop, apprentices will understand:
- Modern infrastructure concepts and cloud platforms
- 3-tier architecture design and deployment
- Infrastructure as Code using Terraform
- Security, monitoring, and best practices
- Integration with DevOps workflows

---

## Workshop Structure

### Part 1: Theory Session (2 hours)
**Time:** 12:00-14:00  
**Format:** Interactive presentation with slides  
**Content:** Foundational concepts and best practices

### Part 2: Practical Labs (2.5 hours)
**Time:** 14:15-16:30  
**Format:** Hands-on exercises with guidance  
**Content:** Deploy real infrastructure using Terraform

### Break (15 minutes)
**Time:** 14:00-14:15  
**Purpose:** Transition between theory and practical sessions

---

## Materials Included

### 📚 Theory Materials
- **`slide-deck.md`** - Complete presentation covering all required topics
- **Theory topics:** Infrastructure concepts, cloud platforms, environments, containers, CI/CD, monitoring, security

### 🛠️ Practical Materials
- **`terraform/`** - Complete Terraform configuration with blanks for apprentices
- **`sample-app/`** - Simple web application for deployment
- **`lab-instructions.md`** - Step-by-step lab guide with tasks
- **`.github/workflows/`** - CI/CD workflows for DevOps integration

### 🔧 Setup and Integration
- **`lab-environment-setup.md`** - Environment setup guide (AWS Educate recommended)
- **`integration-handoff.md`** - Handoff points for DevOps teammate
- **`README.md`** - This overview document

---

## Quick Start Guide

### For Instructors

1. **Review Materials:**
   ```bash
   # Clone or download the workshop materials
   git clone [workshop-repository]
   cd infrastructure-workshop
   
   # Review the slide deck
   open workshop-materials/slide-deck.md
   
   # Review lab instructions
   open workshop-materials/lab-instructions.md
   ```

2. **Set Up Lab Environment:**
   ```bash
   # Follow the environment setup guide
   open workshop-materials/lab-environment-setup.md
   
   # Recommended: AWS Educate accounts for students
   # Alternative: Shared AWS account with IAM users
   ```

3. **Test the Labs:**
   ```bash
   # Navigate to Terraform directory
   cd workshop-materials/terraform
   
   # Test the configuration
   terraform init
   terraform plan -var-file="dev.tfvars"
   ```

4. **Coordinate with DevOps Teammate:**
   ```bash
   # Review integration handoff document
   open workshop-materials/integration-handoff.md
   
   # Share GitHub Actions workflows
   # Plan handoff points and timing
   ```

### For Students

1. **Pre-Workshop Setup:**
   ```bash
   # Access your AWS Educate account
   # Install required tools (if needed)
   # Clone the workshop repository
   ```

2. **During the Workshop:**
   ```bash
   # Follow the slide deck for theory
   # Complete lab exercises with blanks
   # Ask questions and get help
   ```

3. **Post-Workshop:**
   ```bash
   # Clean up resources to avoid charges
   terraform destroy -var-file="student.tfvars"
   
   # Join the DevOps session
   # Practice with additional AWS services
   ```

---

## Workshop Agenda

### Theory Session (12:00-14:00)

| Time | Topic | Duration |
|------|-------|----------|
| 12:00-12:15 | Introduction to Infrastructure | 15 min |
| 12:15-12:45 | Cloud Platforms Overview | 30 min |
| 12:45-13:05 | Environments & Lifecycle | 20 min |
| 13:05-13:30 | Containers vs VMs | 25 min |
| 13:30-14:00 | CI/CD & Deployment Strategies | 30 min |

### Break (14:00-14:15)

### Practical Session (14:15-16:30)

| Time | Lab | Duration |
|------|-----|----------|
| 14:15-14:30 | Environment Setup | 15 min |
| 14:30-15:00 | Infrastructure as Code Basics | 30 min |
| 15:00-16:00 | Deploy 3-Tier Architecture | 60 min |
| 16:00-16:45 | Multi-Environment Deployment | 45 min |
| 16:45-17:05 | Monitoring & Validation | 20 min |

---

## Key Features

### 🎯 Educational Design
- **Progressive Learning:** Builds from basic concepts to complex deployments
- **Hands-on Practice:** Real infrastructure deployment with guidance
- **Blanks and Tasks:** Apprentices fill in missing pieces to learn
- **Real-world Relevance:** Industry-standard tools and practices

### 🔒 Security Focus
- **Least Privilege:** Security groups with minimal required access
- **Encryption:** Data encrypted at rest and in transit
- **Best Practices:** Industry-standard security configurations
- **Cost Management:** Automated cleanup and spending limits

### 🔄 DevOps Integration
- **Clear Handoff:** Defined integration points with DevOps team
- **CI/CD Workflows:** GitHub Actions for infrastructure automation
- **Monitoring:** CloudWatch dashboards and health checks
- **Multi-Environment:** Dev, staging, and production configurations

### 💰 Cost-Effective
- **AWS Educate:** Free credits for students
- **Small Instances:** t2.micro and db.t3.micro for learning
- **Auto-cleanup:** Automated resource destruction
- **Budget Alerts:** Cost monitoring and notifications

---

## Architecture Overview

```
Internet → Application Load Balancer → Auto Scaling Group → EC2 Instances
                                                              ↓
                                                         RDS MySQL
```

### Components Deployed:
- **Web Tier:** Application Load Balancer + Auto Scaling Group
- **Application Tier:** EC2 instances running Apache/PHP
- **Database Tier:** RDS MySQL instance
- **Networking:** VPC with public and private subnets
- **Security:** Security groups with least privilege access
- **Monitoring:** CloudWatch dashboard and metrics

---

## Technology Stack

### Infrastructure
- **Terraform:** Infrastructure as Code
- **AWS:** Cloud platform (EC2, RDS, ELB, VPC, CloudWatch)
- **GitHub Actions:** CI/CD automation
- **Linux:** Ubuntu/Amazon Linux for compute

### Application
- **Apache:** Web server
- **PHP:** Application runtime
- **MySQL:** Database
- **HTML/CSS/JavaScript:** Frontend

### Tools
- **AWS CLI:** Command line interface
- **Git:** Version control
- **cURL:** HTTP testing
- **jq:** JSON processing

---

## Learning Outcomes

### Technical Skills
- ✅ Deploy infrastructure using Terraform
- ✅ Understand 3-tier architecture
- ✅ Configure AWS services and networking
- ✅ Implement security best practices
- ✅ Set up monitoring and health checks
- ✅ Manage multiple environments

### Professional Skills
- ✅ Infrastructure as Code principles
- ✅ Cloud platform knowledge
- ✅ Security awareness
- ✅ Cost optimization
- ✅ Documentation and communication
- ✅ Team collaboration

### Career Development
- ✅ AWS Cloud Practitioner preparation
- ✅ DevOps and automation concepts
- ✅ Industry-standard tools and practices
- ✅ Real-world project experience
- ✅ Portfolio building opportunities

---

## Assessment and Feedback

### Workshop Completion Criteria
- [ ] All lab exercises completed
- [ ] Infrastructure successfully deployed
- [ ] Application accessible and healthy
- [ ] Multi-environment deployment working
- [ ] Monitoring dashboards active
- [ ] Resources cleaned up

### Feedback Collection
- **Pre-workshop survey:** Background and expectations
- **Mid-workshop check:** Progress and understanding
- **Post-workshop survey:** Learning outcomes and satisfaction
- **Follow-up survey:** Application of knowledge

### Success Metrics
- **Completion Rate:** >90% of students complete all labs
- **Satisfaction Score:** >4.0/5.0 average rating
- **Learning Outcomes:** >85% achieve learning objectives
- **Technical Issues:** <5% require instructor intervention

---

## Troubleshooting Guide

### Common Issues

**Environment Setup:**
- AWS Educate account not approved → Use backup shared account
- Tools not installed → Follow installation guide
- Credentials not working → Reconfigure AWS CLI

**Infrastructure Deployment:**
- Terraform errors → Check configuration and permissions
- Resource limits → Verify AWS service quotas
- Network issues → Check security group rules

**Application Issues:**
- Not accessible → Check load balancer health
- Health checks failing → Verify application endpoints
- Database errors → Check connectivity and permissions

### Support Resources
- **Workshop Instructors:** Primary support during session
- **AWS Educate Support:** For account and access issues
- **Documentation:** Comprehensive guides and troubleshooting
- **Community:** Peer support and knowledge sharing

---

## Post-Workshop Follow-up

### Immediate Actions
1. **Clean Up Resources:** Destroy all infrastructure to avoid charges
2. **Complete Feedback:** Fill out workshop evaluation form
3. **Join DevOps Session:** Continue learning with application deployment
4. **Practice More:** Try additional AWS services and configurations

### Continued Learning
1. **AWS Free Tier:** Practice with personal AWS account
2. **Certification Path:** Consider AWS Cloud Practitioner
3. **Projects:** Apply knowledge to personal or academic projects
4. **Community:** Join AWS user groups and forums

### Career Development
1. **Portfolio:** Document workshop projects and learnings
2. **Networking:** Connect with instructors and fellow students
3. **Internships:** Apply for cloud and infrastructure roles
4. **Advanced Training:** Pursue specialized cloud certifications

---

## Resources and Support

### Documentation
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Documentation](https://terraform.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [AWS Educate](https://aws.amazon.com/education/awseducate/)

### Tools and Platforms
- [Terraform](https://terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- [GitHub](https://github.com/)
- [AWS Console](https://console.aws.amazon.com/)

### Support Contacts
- **Workshop Instructors:** [Your Email]
- **DevOps Team:** [DevOps Email]
- **Workshop Coordinators:** [Coordinator Email]
- **Technical Support:** [Support Email]

---

## Workshop Success Factors

### For Instructors
- **Preparation:** Review all materials and test labs beforehand
- **Environment:** Ensure lab environment is ready and tested
- **Support:** Be available to help students with issues
- **Engagement:** Keep students engaged and motivated
- **Integration:** Coordinate effectively with DevOps teammate

### For Students
- **Preparation:** Complete pre-workshop setup and reading
- **Participation:** Ask questions and engage with content
- **Practice:** Complete all lab exercises and tasks
- **Collaboration:** Work with peers and instructors
- **Follow-up:** Clean up resources and continue learning

### For Organizations
- **Resources:** Provide adequate lab environment and tools
- **Support:** Ensure instructors have necessary support
- **Integration:** Coordinate between Infrastructure and DevOps teams
- **Feedback:** Collect and act on workshop feedback
- **Follow-up:** Provide continued learning opportunities

---

## Conclusion

This IT Infrastructure Workshop provides a comprehensive, hands-on learning experience that bridges the gap between theoretical knowledge and practical skills. By combining modern cloud technologies with industry best practices, it prepares university apprentices for careers in cloud computing and infrastructure management.

The workshop's success depends on the collaboration between Infrastructure and DevOps teams, the engagement of students, and the support of the organization. With proper preparation and execution, it will provide valuable learning outcomes and career development opportunities.

**Key Success Factors:**
- Clear learning objectives and progressive difficulty
- Hands-on practice with real-world tools
- Strong integration between Infrastructure and DevOps
- Comprehensive support and troubleshooting
- Cost-effective and accessible lab environment

**Remember:** The goal is not just to complete the workshop, but to build a foundation for continued learning and career development in cloud computing and infrastructure management.

---

## Workshop Materials Checklist

### Pre-Workshop
- [ ] Review slide deck and presentation
- [ ] Test lab environment setup
- [ ] Verify Terraform configurations
- [ ] Coordinate with DevOps teammate
- [ ] Prepare student materials and accounts

### During Workshop
- [ ] Deliver theory session with slides
- [ ] Guide students through lab exercises
- [ ] Provide support and troubleshooting
- [ ] Monitor progress and engagement
- [ ] Coordinate handoff to DevOps team

### Post-Workshop
- [ ] Collect feedback and evaluations
- [ ] Ensure resource cleanup
- [ ] Follow up with students
- [ ] Document lessons learned
- [ ] Plan improvements for next session

---

**Ready to deliver an amazing IT Infrastructure Workshop! 🚀**

---

*This workshop package was created for the University Apprenticeship Programme. All materials are designed to be educational, cost-effective, and aligned with industry best practices.*
