// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RewardForCourseCompletion {

    // Define a structure to represent a course and the reward for each student
    struct Course {
        string courseName;
        uint256 rewardAmount; // The amount of Ether to be rewarded in wei
        bool isCompleted; // Track whether the course has been completed
    }

    address public owner; // The owner of the contract (can be the course administrator)
    mapping(address => Course[]) public studentCourses; // Mapping from student address to their courses

    event CourseCompleted(address indexed student, string courseName, uint256 rewardAmount);
    event RewardClaimed(address indexed student, uint256 totalReward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender; // The account deploying the contract is the owner
    }

    // Function to enroll a student in a course
    function enrollStudentInCourse(address student, string memory courseName, uint256 rewardAmount) public onlyOwner {
        studentCourses[student].push(Course({
            courseName: courseName,
            rewardAmount: rewardAmount,
            isCompleted: false
        }));
    }

    // Function to mark a course as completed for a student
    function markCourseCompleted(address student, uint256 courseIndex) public onlyOwner {
        require(courseIndex < studentCourses[student].length, "Course index out of range.");
        Course storage course = studentCourses[student][courseIndex];
        require(!course.isCompleted, "Course already completed.");

        course.isCompleted = true;

        // Emit an event when a course is completed
        emit CourseCompleted(student, course.courseName, course.rewardAmount);
    }

    // Function for students to claim their rewards for completed courses
    function claimReward() public {
        uint256 totalReward = 0;

        // Loop through the student's courses and add up the rewards for completed courses
        for (uint256 i = 0; i < studentCourses[msg.sender].length; i++) {
            Course storage course = studentCourses[msg.sender][i];
            if (course.isCompleted) {
                totalReward += course.rewardAmount;
            }
        }

        require(totalReward > 0, "No rewards to claim.");

        // Reset the student's courses after they have claimed their rewards
        delete studentCourses[msg.sender];

        // Transfer the reward to the student
        payable(msg.sender).transfer(totalReward);

        // Emit an event when the student claims their reward
        emit RewardClaimed(msg.sender, totalReward);
    }

    // Function to fund the contract with Ether (only the owner can fund it)
    function fundContract() public payable onlyOwner {}

    // Function to withdraw funds (only the owner can withdraw)
    function withdrawFunds(uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient funds.");
        payable(owner).transfer(amount);
    }

    // A fallback function to accept Ether transfers
    receive() external payable {}
}
