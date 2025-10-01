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

### 💡 Next Action

**Based on the current state, the most likely issue is:**

The file might have been uploaded with different metadata or there might be a caching issue. The best next step is:

**Re-upload the instructor-dashboard.html file:**
1. Delete it from S3
2. Upload it fresh
3. Make sure it uploads successfully
4. Test immediately

If that doesn't work, we'll check the file metadata and encryption settings next.

