# Workshop Troubleshooting Log
Date: 2025-09-30

---

## Issue: Instructor Dashboard - Access Denied (403 Forbidden)

### Error Details
**Error Message:**
```xml
<Error>
  <Code>AccessDenied</Code>
  <Message>Access Denied</Message>
  <RequestId>R6Y7JXP1EQA53BF4</RequestId>
  <HostId>843EBmEvk7L161BCqyThagemtJpbwgHgfQON8cfnP8RZqSEdrnXnAaz0R8orLV/8W6nl9TQhaAU=</HostId>
</Error>
```

**Attempting to Access:**
`http://infrastructure-workshop-2025-registration-535002854646.s3-website-us-east-1.amazonaws.com/instructor-dashboard.html`

---

### ✅ Already Verified (DO NOT CHECK AGAIN)

1. **Block Public Access Settings:**
   - ✅ "Block all public access" is **OFF**
   - ✅ All individual block settings are **OFF**

2. **Bucket Policy:**
   - ✅ Policy exists and allows `s3:GetObject` on all `*.html` files
   - ✅ Policy resource includes wildcard: `arn:aws:s3:::infrastructure-workshop-2025-registration-535002854646/*`
   - ✅ Principal is set to `*` (public access)

3. **Files Exist:**
   - ✅ `index.html` exists (5.2 KB, uploaded 14:32:04)
   - ✅ `instructor-dashboard.html` exists (26.0 KB, uploaded 15:46:07)

4. **Static Website Hosting:**
   - ✅ Status: **Enabled**
   - ✅ Index document: `index.html`
   - ✅ Using S3 website endpoint URL (not object URL)

5. **Object Ownership:**
   - ✅ Bucket owner enforced (ACLs disabled - this is correct)

6. **index.html Accessibility:**
   - ✅ index.html works fine at the root URL
   - ✅ Registration form loads and functions correctly

---

### ❌ Current Problem

**Symptom:** `instructor-dashboard.html` returns 403 Access Denied when accessed via S3 website endpoint

**Puzzling Fact:** `index.html` works fine, but `instructor-dashboard.html` doesn't, even though:
- Both files are in the same bucket
- Both files are covered by the same bucket policy
- Both files have the same permissions
- Both files exist and are uploaded

---

### 🔍 Remaining Troubleshooting Steps

#### Step 1: Verify Bucket Policy is Actually Applied
**Action:** Download the current bucket policy from S3 console and verify it matches what we expect

**Expected Policy:**
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::infrastructure-workshop-2025-registration-535002854646/*"
        }
    ]
}
```

#### Step 2: Check File Metadata
**Action:** Check if `instructor-dashboard.html` has different metadata or encryption settings than `index.html`

**How to Check:**
1. Click on `instructor-dashboard.html` in S3
2. Go to "Properties" tab
3. Check "Server-side encryption"
4. Check "Metadata" section
5. Compare with `index.html`

#### Step 3: Re-upload instructor-dashboard.html
**Action:** Delete and re-upload the file to ensure it has the same settings as index.html

**Steps:**
1. Delete `instructor-dashboard.html`
2. Upload it again with the same method used for `index.html`
3. Test access immediately after upload

#### Step 4: Check for Bucket-Level Restrictions
**Action:** Check if there are any other policies or settings blocking access

**How to Check:**
1. Go to bucket "Permissions" tab
2. Check "Access Analyzer findings"
3. Check if there's a "Bucket policy for public access" warning
4. Look for any other restrictions or policies

#### Step 5: Test with Different File Name
**Action:** Rename instructor-dashboard.html to something simpler to rule out filename issues

**Steps:**
1. Copy `instructor-dashboard.html` and rename to `dashboard.html`
2. Upload `dashboard.html`
3. Try accessing: `http://...s3-website.../dashboard.html`

---

### 💡 Actions Taken

#### Attempt 1: Re-upload instructor-dashboard.html
**Result:** ❌ Still getting 403 Access Denied

**Error Details:**
```html
<Code>AccessDenied</Code>
<Message>Access Denied</Message>
<Key>error.html</Key> (trying to load error.html which doesn't exist)
```

---

### 🔍 Current Hypothesis

The 403 error is showing that S3 is trying to load `error.html` as a custom error document. This suggests:

1. **The file itself might be returning an error** (404 or similar)
2. **S3 static website hosting** is configured to use `error.html` for errors
3. **But `error.html` doesn't exist**, causing a secondary error

**This creates a cascade:**
1. User tries to access `instructor-dashboard.html`
2. S3 returns an error (possibly 404 - file not found)
3. S3 tries to serve `error.html` as custom error page
4. `error.html` doesn't exist
5. User sees "Access Denied" + "NoSuchKey: error.html"

---

### 🎯 Next Action: Test File Existence

**Step 1: Verify the file is actually accessible**

Try accessing the file via the S3 object URL (not website endpoint):
`https://infrastructure-workshop-2025-registration-535002854646.s3.amazonaws.com/instructor-dashboard.html`

**Expected Results:**
- If this works → File exists, issue is with static website hosting config
- If this fails → File upload issue or encryption/metadata problem

**Step 2: Compare with index.html**

Try accessing index.html via S3 object URL:
`https://infrastructure-workshop-2025-registration-535002854646.s3.amazonaws.com/index.html`

**Compare the results** - if index.html works via object URL but instructor-dashboard.html doesn't, there's a file-specific issue.

**Step 3: Create error.html**

Since static website hosting is looking for `error.html`, create a simple one:

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Error</title>
</head>
<body>
    <h1>Error</h1>
    <p>Something went wrong. Please go back and try again.</p>
</body>
</html>
```

Upload this as `error.html` to stop the secondary error.

---

### 🚨 CRITICAL FINDING

**Test Result:** BOTH index.html and instructor-dashboard.html return Access Denied via S3 object URL

**URLs Tested:**
- `https://infrastructure-workshop-2025-registration-535002854646.s3.amazonaws.com/index.html` → ❌ Access Denied
- `https://infrastructure-workshop-2025-registration-535002854646.s3.amazonaws.com/instructor-dashboard.html` → ❌ Access Denied

**Conclusion:** The bucket policy is NOT working for S3 object URLs

**However:**
- ✅ index.html WORKS via S3 website endpoint: `http://...s3-website-us-east-1.amazonaws.com/index.html`
- ❌ instructor-dashboard.html FAILS via S3 website endpoint: `http://...s3-website-us-east-1.amazonaws.com/instructor-dashboard.html`

**This tells us:**
1. The bucket policy works for static website hosting
2. index.html is correctly configured for static website hosting
3. instructor-dashboard.html has a specific issue preventing it from being served via static website hosting

---

### 🎯 New Investigation: File-Specific Issue

**Hypothesis:** The instructor-dashboard.html file has a specific problem:
- Wrong file encoding
- File corruption during upload
- File name has invisible characters
- File size too large (26KB vs 5.2KB for index.html)

**Next Systematic Steps:**

#### Step 1: Check File Name for Hidden Characters
In S3 Console:
1. Click on `instructor-dashboard.html`
2. Check the exact object key (might have spaces or special characters)
3. Copy the exact key name

#### Step 2: Rename the File to Something Simple
1. In your local folder, rename `instructor-dashboard.html` to `dashboard.html`
2. Upload as `dashboard.html`
3. Test: `http://...s3-website-us-east-1.amazonaws.com/dashboard.html`

#### Step 3: Check File Size Limits
The file is 26KB vs index.html's 5.2KB. While this shouldn't be an issue, let's verify:
1. Check if there are any size-based restrictions
2. Try creating a minimal version of instructor-dashboard.html
3. Upload and test

#### Step 4: Check File Encoding
1. Open instructor-dashboard.html in a text editor
2. Save as UTF-8 without BOM
3. Re-upload
4. Test

---

### 💡 Immediate Action

**Try renaming the file to `dashboard.html` and uploading:**
1. Rename locally: `instructor-dashboard.html` → `dashboard.html`
2. Upload to S3 as `dashboard.html`
3. Test: `http://infrastructure-workshop-2025-registration-535002854646.s3-website-us-east-1.amazonaws.com/dashboard.html`

This will help us determine if the issue is with the filename itself.

---

### ⚠️ Test Result: Renaming Failed

**Attempt 2: Renamed to dashboard.html**
**Result:** ❌ Still getting 403 Access Denied

**This eliminates filename as the issue.**

---

### 🔍 New Discovery: Static Website Hosting Error Document

The error message keeps mentioning:
```
An Error Occurred While Attempting to Retrieve a Custom Error Document
Key: error.html
```

**This means:**
1. S3 static website hosting is configured to use `error.html` as the error document
2. When ANY file returns an error, S3 tries to serve `error.html`
3. `error.html` doesn't exist, causing a secondary error

**Critical Question:** Why is index.html working via website endpoint but dashboard.html isn't?

---

### 🎯 New Hypothesis: Index Document vs Regular Files

**Observation:**
- `index.html` works via website endpoint ✅
- `dashboard.html` fails via website endpoint ❌
- BOTH fail via object URL ❌

**Possible Explanation:**
The bucket might be configured to ONLY serve the index document (`index.html`) and not allow access to other files!

---

### 💡 Next Action: Check Static Website Hosting Configuration

**Step 1: Verify Static Website Hosting Settings**

In S3 Console → Properties → Static website hosting:
1. What is the **exact configuration**?
2. Is there a "Redirection rules" section with any rules?
3. Is there a "Hosting type" set to "Redirect requests"?

**Step 2: Test Root URL**

Try accessing just the root:
`http://infrastructure-workshop-2025-registration-535002854646.s3-website-us-east-1.amazonaws.com/`

Does this work?

**Step 3: Create error.html to Stop Secondary Error**

Create a simple `error.html` and upload it to stop the confusing secondary error message.

---

### 🔧 Alternative Solution: Use CloudFront or Different Hosting

If S3 static website hosting continues to have issues, we could:
1. Use AWS CloudFront distribution
2. Use AWS Amplify hosting
3. Use a simple EC2 instance with nginx
4. Host the dashboard differently from the registration page

But first, let's understand why the static website hosting is behaving this way.

---

## Issue: Account Creation Not Completing

### Problem Summary

**Symptom:** Registration returns success message but accounts don't appear in Workshop-Students OU

**Root Cause:** Lambda function has an early return statement that exits before completing account setup

**CloudWatch Logs Show:**
```
[INFO] Account creation initiated for conor.macklin1986@gmail.com: car-8451a1f9cfdc45a093f11a71bda74857
END RequestId: 948cf11f-bf38-403f-94e5-ea9db31fa0d0
```

**What's Happening:**
1. ✅ Lambda function receives request
2. ✅ Account creation is initiated (`organizations.create_account()`)
3. ✅ Function returns success with create_request_id
4. ❌ Function exits BEFORE moving account to Workshop-Students OU
5. ❌ Function exits BEFORE creating SSO user
6. ❌ Function exits BEFORE setting up budget
7. ❌ Function exits BEFORE sending welcome email

### Architecture Issue

**The Fundamental Problem:**
- `organizations.create_account()` is **asynchronous**
- It returns a `create_request_id` immediately
- But the actual account isn't ready for **5-10 minutes**
- Lambda has a **max timeout of 15 minutes**
- Waiting in Lambda is inefficient and may timeout

**Current Code Structure:**
```python
Line 70: account_result = create_aws_account(email, name)  # Returns request ID
Line 83: return create_response(200, {...})  # Returns immediately
Line 96+: move_account_to_workshop_ou(account_id)  # NEVER EXECUTES (after return)
```

### Solution Options

**Option 1: Remove Early Return (Simple but Inefficient)**
- Remove the early return statement
- Wait for account to be ready
- Complete all setup in one Lambda execution
- **Downside:** Users wait 5-10 minutes for response, Lambda may timeout

**Option 2: Use AWS Step Functions (Production-Ready)**
- Use Step Functions to orchestrate the workflow
- Lambda initiates account creation
- Step Functions wait for account to be ready
- Subsequent steps move account, create SSO user, etc.
- **Downside:** More complex, requires additional AWS service

**Option 3: Use EventBridge + Second Lambda (Recommended)**
- First Lambda: Creates account, returns immediately
- EventBridge: Monitors Organizations events
- Second Lambda: Triggered when account is ready, completes setup
- **Downside:** Requires additional Lambda function

**Option 4: Manual Completion (Quick Fix)**
- Keep early return
- Account is created in root organization
- Manually move accounts to Workshop-Students OU periodically
- Manually trigger budget/SSO setup
- **Downside:** Manual work required

### Recommended Immediate Fix

For your workshop use case, **Option 1** is simplest:

1. The Lambda function should complete ALL steps before returning
2. Users see a loading message for 5-10 minutes
3. Once account is ready, they get confirmation
4. Everything is set up properly

**Implementation:** Remove the early return and let the full flow complete.

