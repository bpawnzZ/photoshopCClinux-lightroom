# 🎯 AGENT TEAM DEBUGGING PROMPT

## 📋 MISSION BRIEFING

**Project**: Adobe Photoshop & Lightroom CC Setup for Linux  
**Codebase**: `photoshopCClinux` repository  
**Primary Issue**: Intelligent dependency management and cross-distro portability  
**Your Role**: Lead Agent orchestrating a team to debug and fix this codebase

## 📚 REQUIRED READING (CRITICAL)

Before starting, **READ THESE FILES COMPLETELY**:
1. `ADOBE_SETUP_ARCHITECTURE.md` - Comprehensive architecture documentation
2. `README.md` - User documentation and requirements
3. `TEST_PLAN.md` - Test cases and validation procedures
4. Recent git commit history - Understand recent changes and fixes

## 🎯 CORE OBJECTIVES

### 1. **Validate Intelligent Dependency Management**
- Verify that Photoshop and Lightroom share the same Wine prefix
- Confirm dependency checking works (doesn't reinstall already installed components)
- Test installation order permutations (Photoshop→Lightroom, Lightroom→Photoshop)

### 2. **Ensure Cross-Distribution Portability**
- Test on simulated Arch, Debian/Ubuntu, Fedora environments
- Verify package manager detection works correctly
- Confirm 32-bit architecture handling is distribution-appropriate

### 3. **Fix Any Remaining "wine64: command not found" Issues**
- This was the original reported bug
- Ensure all symlink fallbacks work
- Test on systems with only `wine`, only `wine64`, or both

### 4. **Improve Error Handling and User Experience**
- Clear error messages with actionable solutions
- Graceful degradation when features aren't available
- Better logging for debugging future issues

## 👥 AGENT TEAM STRUCTURE

### **Team Lead** (You)
- Orchestrate the team
- Synthesize findings
- Make architectural decisions
- Communicate with stakeholders

### **Agent 1: Architecture Validator**
- **Focus**: Validate the shared Wine prefix architecture
- **Tasks**:
  1. Trace Wine prefix usage across all scripts
  2. Verify `check_wine_prefix()` and `check_adobe_app_installed()` functions
  3. Test that dependencies aren't reinstalled unnecessarily
  4. Check for any remaining `rmdir_if_exist` calls on Wine prefix

### **Agent 2: Distribution Tester**
- **Focus**: Cross-distro compatibility
- **Tasks**:
  1. Simulate different Linux distributions (Arch, Ubuntu, Fedora)
  2. Test package manager detection logic
  3. Verify dependency installation commands are distro-correct
  4. Test 32-bit architecture enablement for Debian/Ubuntu

### **Agent 3: Wine & Dependency Expert**
- **Focus**: Wine-specific issues and dependency management
- **Tasks**:
  1. Test all Wine symlink fallback scenarios
  2. Verify `check_winetricks_component()` registry checking
  3. Test `install_missing_dependencies()` logic
  4. Validate winetricks component installation

### **Agent 4: User Experience & Error Handler**
- **Focus**: Error messages, logging, and user interaction
- **Tasks**:
  1. Review all error messages for clarity and actionability
  2. Test edge cases (no network, no sudo, insufficient permissions)
  3. Verify logging works correctly in all scenarios
  4. Test user confirmation prompts

## 🔍 DEBUGGING METHODOLOGY

### Phase 1: Code Analysis
```
1. Map the call graph: setup.sh → [scripts] → sharedFuncs.sh
2. Identify all Wine-related functions and their interactions
3. Trace Wine prefix lifecycle (creation, checking, modification)
4. Document dependency installation flow
```

### Phase 2: Scenario Testing
```
Test these scenarios systematically:
1. Fresh system, install Photoshop first
2. Fresh system, install Lightroom first  
3. Install Photoshop, then Lightroom (check dependency reuse)
4. Install Lightroom, then Photoshop (check dependency reuse)
5. Reinstall already installed application
6. Install Camera Raw after Photoshop
7. Complete uninstall and reinstall
```

### Phase 3: Distribution Testing
```
Simulate environments:
1. Arch Linux with pacman
2. Ubuntu/Debian with apt
3. Fedora with dnf
4. System with only wine (no wine64)
5. System with only wine64 (no wine)
6. System with wine-staging
```

### Phase 4: Edge Case Testing
```
1. No internet connection during download
2. No sudo permissions for symlink creation
3. Insufficient disk space
4. Corrupted Wine prefix
5. Missing 32-bit library support
6. Conflicting existing installations
```

## 🛠️ TOOLS & TECHNIQUES

### Available Tools
- **Code Analysis**: `grep`, `bash -n`, function tracing
- **Testing**: Simulated environments, dry-run modes
- **Logging**: Check `wine-error.log`, `setuplog.log`
- **Validation**: `test_package_functions.sh`

### Debugging Techniques
1. **Add Debug Logging**: Temporary echo statements to trace execution
2. **Dry Run Testing**: Test without actual installation where possible
3. **Function Isolation**: Test individual functions in isolation
4. **Registry Inspection**: Check Wine registry files for component installation
5. **Path Tracing**: Follow `SCR_PATH`, `WINE_PREFIX` variable usage

## 📝 EXPECTED DELIVERABLES

### 1. **Bug Report**
- List of all issues found, categorized by severity
- Reproduction steps for each issue
- Root cause analysis

### 2. **Fix Implementation**
- Code changes to fix identified issues
- Updated tests to prevent regression
- Documentation updates if architecture changes

### 3. **Validation Report**
- Test matrix showing what scenarios were tested
- Results for each test case
- Remaining known issues or limitations

### 4. **Architecture Recommendations**
- Suggestions for future improvements
- Security considerations
- Performance optimizations

## ⚠️ CRITICAL WARNINGS

### **DO NOT BREAK THESE CORE PRINCIPLES**
1. **Shared Wine Prefix**: Photoshop and Lightroom MUST share the same prefix
2. **Intelligent Dependency Checking**: Never revert to always-install-all approach
3. **Cross-Distro Portability**: Maintain distribution detection and appropriate handling
4. **User Safety**: Always ask before destructive operations

### **COMMON PITFALLS TO AVOID**
1. **Assuming Arch Linux**: Always check distribution first
2. **Hardcoding Paths**: Use variables from `sharedFuncs.sh`
3. **Missing Error Handling**: Every external command should have error checking
4. **Overlooking 32-bit Support**: Wine needs 32-bit libraries even on 64-bit systems

## 🚀 EXECUTION CHECKLIST

### Before Starting
- [ ] Read all documentation thoroughly
- [ ] Understand the git history and recent fixes
- [ ] Set up testing environment
- [ ] Create backup of current codebase

### During Debugging
- [ ] Test one scenario at a time
- [ ] Document findings immediately
- [ ] Validate fixes don't break other scenarios
- [ ] Check log files after each test

### Before Completion
- [ ] Run all existing tests
- [ ] Test all installation order permutations
- [ ] Verify cross-distro compatibility
- [ ] Ensure no regression in error handling

## 📞 COMMUNICATION PROTOCOL

### Status Updates
- Daily progress reports
- Immediate notification of critical issues
- Architecture decision points for team lead review

### Issue Escalation
- **Low**: Minor bugs, cosmetic issues
- **Medium**: Functional issues in non-critical paths
- **High**: Breaks core functionality (shared prefix, dependency checking)
- **Critical**: Security issues, data loss risks

## 🏁 SUCCESS CRITERIA

The debugging mission is successful when:

1. **All original reported bugs are fixed** (especially "wine64: command not found")
2. **Intelligent dependency management works correctly** (no duplicate installations)
3. **Cross-distro portability is verified** (Arch, Debian, Fedora at minimum)
4. **Error handling is robust and user-friendly**
5. **No regression in existing functionality**
6. **Documentation is updated to reflect any changes**

**Remember**: This is a complex system with many interacting components. Methodical testing and careful changes are more important than speed. When in doubt, preserve the core architecture principles documented in `ADOBE_SETUP_ARCHITECTURE.md`.

**Good luck, Agent Team!** 🚀