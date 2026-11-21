# Living documentation for the container mode of the docs-toolbox task runner
# (templates/scripts/build.sh, and the same container call in build.sh and
# scripts/render-presentation.sh).
# Bridged to: test/build-sh-template.test.mjs (node:test, classic runner, no
# native BDD). The scenario maps to one test per engine, named after the
# scenario title plus the engine. Traceability is a reviewer-verifiable
# convention, not a build-enforced link.
#
# The tests run the runner against stub engines and check the arguments it
# passes. That the JVM in the image then writes no font cache into the project
# was checked once with a real Podman build (issue #114); Docker itself is not
# checked.

Feature: Container build
  As a maintainer of a consuming project
  I want the containerised documentation build to leave my project tree alone
  So that a build does not create files I have to ignore or delete

  Scenario Outline: Container build keeps the JVM home out of the project
    Given a consuming project with the task runner at its root
    And the container engine "<engine>"
    When a documentation task runs in container mode
    Then the JVM in the container gets /tmp as its home directory, not the mounted project

    Examples:
      | engine |
      | podman |
      | docker |
