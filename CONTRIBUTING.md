# Contributing to Server Status Report Script

We welcome contributions to the `server_status_report.sh` project! By contributing, you help make this utility more robust, portable, and useful for system administrators everywhere.

## How to Contribute

There are several ways you can contribute to this project:

### 🐛 Reporting Bugs

If you find a bug (e.g., incorrect reporting, argument parsing errors, or compatibility issues), please:

1. **Check existing issues** to see if the bug has already been reported.

2. **Open a new issue** and include the following information:

   * A clear, descriptive **title**.

   * The **steps to reproduce** the bug.

   * The **expected behavior** vs. the **actual behavior**.

   * Your **Linux distribution** and **Bash version** (`bash --version`).

### 💡 Suggesting Enhancements

We are always looking for ways to improve the script. Suggestions can include:

* New metrics to report (e.g., I/O usage, network statistics).

* Better visualization techniques.

* Improvements to error handling or dependency checks.

Please open an issue with the label `enhancement` and describe your idea thoroughly.

### 💻 Code Contributions (Pull Requests)

We encourage you to submit Pull Requests (PRs) with fixes or new features.

1. **Fork the repository.**

2. **Create a descriptive branch** (`git checkout -b feature/your-feature-name` or `git checkout -b bugfix/issue-number`).

3. **Make your changes.**

   * Adhere to standard **ShellCheck** best practices (e.g., quote variables).

   * Prioritize **portability** (avoiding reliance on non-standard tools).

   * Use **pure integer math** where possible to keep the dependency list minimal.

4. **Update the version number** in the header of `server_status_report.sh` (e.g., from `1.0.8` to `1.0.9`).

5. **Test your changes** on different Linux distributions if possible.

6. **Commit your changes** with a clear and concise commit message.

7. **Submit a Pull Request** against the `main` branch, clearly explaining the changes and referencing any related issues.

## Style Guide

* **Variables:** Use all caps for global/environment variables, and lower\_case for temporary script variables.

* **Functions:** Use lowercase and underscores (`function_name`).

* **Formatting:** Maintain the existing header and reporting formats (especially the use of dashes for section separation) to keep the email report consistent.