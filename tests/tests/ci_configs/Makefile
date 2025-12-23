
.PHONY: test test-unit test-integration test-performance test-ui report clean install

# Install required packages
install:
	@echo "Installing R packages..."
	@Rscript -e "install.packages(c(\"shiny\", \"bslib\", \"DT\", \"dplyr\", \"testthat\", \"htmltools\", \"microbenchmark\"))"

# Run all tests
test: install
	@echo "Running all tests..."
	@Rscript tests/run_guided_workflow_tests.R

# Run specific test suites
test-unit:
	@echo "Running unit tests..."
	@Rscript -e "testthat::test_file(\"tests/testthat/test-guided-workflow.R\")"

test-integration:
	@echo "Running integration tests..."
	@Rscript -e "testthat::test_file(\"tests/testthat/test-guided-workflow-integration.R\")"

test-performance:
	@echo "Running performance tests..."
	@Rscript -e "testthat::test_file(\"tests/testthat/test-guided-workflow-performance.R\")"

test-ui:
	@echo "Running UI tests..."
	@Rscript -e "testthat::test_file(\"tests/testthat/test-guided-workflow-ui.R\")"

# Generate HTML report
report:
	@echo "Generating test report..."
	@Rscript tests/generate_test_report.R

# Interactive test app
test-interactive:
	@echo "Starting interactive test app..."
	@Rscript tests/test_guided_workflow_interactive.R

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	@rm -rf tests/reports/*
	@rm -rf rlib/*

# Run tests in Docker
test-docker:
	@echo "Running tests in Docker..."
	@docker-compose -f docker-compose.test.yml up --abort-on-container-exit

# Watch mode - run tests on file changes
watch:
	@echo "Watching for changes..."
	@while true; do \
		inotifywait -e modify guided_workflow.r tests/**/*.R; \
		make test; \
	done

