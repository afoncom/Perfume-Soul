//
//  CalculationLoadingPresenterTests.swift
//  PerfumeSoulTests
//

import XCTest
import UIKit
import CoreData
@testable import PerfumeSoul

final class CalculationLoadingPresenterTests: XCTestCase {
    @MainActor
    func testInvalidBirthDataRequiresEditingInsteadOfRetrying() async {
        let viewModel = CalculationLoadingViewModel()
        let router = LoadingRouterMock()
        let calculationService = LoadingCalculationServiceMock()
        let presenter = makePresenter(
            viewModel: viewModel,
            router: router,
            calculationService: calculationService
        )

        await presenter.onAppear()
        presenter.retryButtonTapped()
        await presenter.onAppear()

        XCTAssertEqual(viewModel.failure, .invalidBirthData)
        XCTAssertEqual(calculationService.calculationCount, 1)
        XCTAssertEqual(router.descriptionCount, 0)
        presenter.editBirthDataTapped()
        XCTAssertEqual(router.editCount, 1)
    }

    @MainActor
    func testCannotReturnToBirthDataWhileCalculationIsRunning() async throws {
        let form = UIViewController()
        let loadingScreen = UIViewController()
        let navigationController = UINavigationController(rootViewController: form)
        navigationController.setViewControllers([form, loadingScreen], animated: false)
        navigationController.loadViewIfNeeded()
        let gesture = try XCTUnwrap(navigationController.interactivePopGestureRecognizer)
        gesture.isEnabled = true
        let router = CalculationLoadingRouterImpl(
            navigationController: navigationController,
            container: NSPersistentContainer(name: "PerfumeSoul"),
            requestManager: LoadingRequestManagerMock()
        ) { }
        let calculationService = LoadingCalculationServiceMock()
        let started = expectation(description: "Calculation started")
        var continuation: CheckedContinuation<ProfileCalculation, Error>?
        calculationService.calculateHandler = { _ in
            try await withCheckedThrowingContinuation {
                continuation = $0
                started.fulfill()
            }
        }
        let presenter = makePresenter(
            viewModel: CalculationLoadingViewModel(),
            router: router,
            calculationService: calculationService
        )
        let task = Task { await presenter.onAppear() }
        await fulfillment(of: [started], timeout: 1)

        presenter.editBirthDataTapped()

        XCTAssertFalse(gesture.isEnabled)
        XCTAssertTrue(navigationController.topViewController === loadingScreen)
        task.cancel()
        continuation?.resume(throwing: CancellationError())
        await task.value
        XCTAssertTrue(gesture.isEnabled)
    }

    @MainActor
    func testSuccessSavesCalculationBeforeOpeningProfileDescription() async {
        let viewModel = CalculationLoadingViewModel()
        let profileService = LoadingProfileServiceMock()
        let router = LoadingRouterMock()
        let calculationService = LoadingCalculationServiceMock()
        let calculation = makeCalculation()
        calculationService.calculateHandler = { _ in calculation }
        router.onDescription = {
            XCTAssertEqual(profileService.profile.cachedProfileCalculation, calculation)
        }
        let presenter = makePresenter(
            viewModel: viewModel,
            router: router,
            calculationService: calculationService,
            profileService: profileService
        )

        await presenter.onAppear()

        XCTAssertNil(viewModel.failure)
        XCTAssertEqual(router.descriptionCount, 1)
        XCTAssertEqual(router.editCount, 0)
    }

    @MainActor
    func testNoInternetShowsOfflineWithoutNavigatingAway() async {
        let viewModel = CalculationLoadingViewModel()
        let router = LoadingRouterMock()
        let calculationService = LoadingCalculationServiceMock()
        calculationService.calculateHandler = { _ in throw URLError(.notConnectedToInternet) }
        let presenter = makePresenter(
            viewModel: viewModel,
            router: router,
            calculationService: calculationService
        )

        await presenter.onAppear()

        XCTAssertEqual(viewModel.failure, .offline)
        XCTAssertEqual(router.descriptionCount, 0)
        XCTAssertEqual(router.editCount, 0)
    }

    @MainActor
    func testServerErrorShowsFailureWithoutNavigatingAway() async {
        let viewModel = CalculationLoadingViewModel()
        let router = LoadingRouterMock()
        let calculationService = LoadingCalculationServiceMock()
        calculationService.calculateHandler = { _ in
            throw RequestManagerError.serverError(statusCode: 503, reason: nil)
        }
        let presenter = makePresenter(
            viewModel: viewModel,
            router: router,
            calculationService: calculationService
        )

        await presenter.onAppear()

        XCTAssertEqual(viewModel.failure, .failed)
        XCTAssertEqual(router.descriptionCount, 0)
        XCTAssertEqual(router.editCount, 0)
    }

    @MainActor
    func testRetryAfterNetworkErrorOpensCalculatedProfile() async {
        let viewModel = CalculationLoadingViewModel()
        let router = LoadingRouterMock()
        let profileService = LoadingProfileServiceMock()
        let calculationService = LoadingCalculationServiceMock()
        calculationService.calculateHandler = { _ in throw URLError(.networkConnectionLost) }
        let presenter = makePresenter(
            viewModel: viewModel,
            router: router,
            calculationService: calculationService,
            profileService: profileService
        )
        await presenter.onAppear()
        XCTAssertEqual(viewModel.failure, .offline)
        let calculation = makeCalculation()
        calculationService.calculateHandler = { _ in calculation }
        let previousRetryAttempt = viewModel.retryAttempt

        presenter.retryButtonTapped()
        XCTAssertNotEqual(viewModel.retryAttempt, previousRetryAttempt)
        await presenter.onAppear()

        XCTAssertNil(viewModel.failure)
        XCTAssertEqual(profileService.profile.cachedProfileCalculation, calculation)
        XCTAssertEqual(router.descriptionCount, 1)
    }

    @MainActor
    func testCancelledRetryDoesNotSaveOrOpenLateCalculation() async {
        let viewModel = CalculationLoadingViewModel()
        let router = LoadingRouterMock()
        let profileService = LoadingProfileServiceMock()
        let calculationService = LoadingCalculationServiceMock()
        calculationService.calculateHandler = { _ in throw URLError(.notConnectedToInternet) }
        let presenter = makePresenter(
            viewModel: viewModel,
            router: router,
            calculationService: calculationService,
            profileService: profileService
        )
        await presenter.onAppear()
        let started = expectation(description: "Retry started")
        var continuation: CheckedContinuation<ProfileCalculation, Error>?
        calculationService.calculateHandler = { _ in
            try await withCheckedThrowingContinuation {
                continuation = $0
                started.fulfill()
            }
        }
        presenter.retryButtonTapped()
        let task = Task { await presenter.onAppear() }
        await fulfillment(of: [started], timeout: 1)

        task.cancel()
        continuation?.resume(returning: makeCalculation())
        await task.value

        XCTAssertNil(profileService.profile.cachedProfileCalculation)
        XCTAssertEqual(router.descriptionCount, 0)
        XCTAssertEqual(router.editCount, 0)
    }

    private func makePresenter(
        viewModel: CalculationLoadingViewModel,
        router: CalculationLoadingRouter,
        calculationService: LoadingCalculationServiceMock,
        profileService: LoadingProfileServiceMock = LoadingProfileServiceMock()
    ) -> CalculationLoadingPresenterImpl {
        CalculationLoadingPresenterImpl(
            viewModel: viewModel,
            router: router,
            profileService: profileService,
            profileCalculationService: calculationService
        ) { _ in
            try Task.checkCancellation()
        }
    }

    private func makeCalculation() -> ProfileCalculation {
        ProfileCalculation(
            natalChart: NatalChart(
                sun: ZodiacPlacement(sign: .cancer, longitude: 105.4),
                moon: ZodiacPlacement(sign: .aquarius, longitude: 318.2),
                ascendant: ZodiacPlacement(sign: .libra, longitude: 190.1)
            ),
            elementBalance: ElementBalance(fire: 0, earth: 0, air: 60, water: 40)
        )
    }
}

private final class LoadingRouterMock: CalculationLoadingRouter {
    var descriptionCount = 0
    var editCount = 0
    var onDescription: (() -> Void)?

    func setBackNavigationEnabled(_ isEnabled: Bool) { }

    func showProfileDescription() {
        onDescription?()
        descriptionCount += 1
    }

    func showCalculationScreen() {
        editCount += 1
    }
}

private final class LoadingRequestManagerMock: RequestManager {
    func sendRequest<Response: Decodable>(request: Request) async throws -> Response {
        throw URLError(.unsupportedURL)
    }
}

private final class LoadingProfileServiceMock: ProfileService {
    var profile = Profile(
        name: "Alex",
        birthDate: "01.01.1990",
        birthTime: "12:00",
        birthPlace: "Madrid, Spain",
        birthLatitude: 40.4168,
        birthLongitude: -3.7038,
        birthTimeZoneIdentifier: "Europe/Madrid"
    )

    func saveProfile(_ profile: Profile) { }
    func deleteProfile(_ profile: Profile) async { }

    func replaceProfile(_ profile: Profile) async {
        self.profile = profile
    }

    func fetchProfile() async -> Profile? { profile }
}

private final class LoadingCalculationServiceMock: ProfileCalculationService {
    var calculationCount = 0
    var calculateHandler: @MainActor (Profile) async throws -> ProfileCalculation = { _ in
        throw ProfileCalculationError.invalidProfileData
    }

    func calculate(profile: Profile) async throws -> ProfileCalculation {
        calculationCount += 1
        return try await calculateHandler(profile)
    }
}
