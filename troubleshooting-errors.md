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

