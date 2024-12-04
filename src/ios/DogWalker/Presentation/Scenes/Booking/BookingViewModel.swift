// Foundation framework - Latest
import Foundation

// MARK: - Human Tasks
/*
Prerequisites:
1. Configure proper error handling and monitoring for booking operations
2. Set up proper logging for booking state changes
3. Review and implement proper data retention policies for booking data
4. Ensure proper notification handling for booking updates
*/

/// BookingViewModel: Manages the state and logic for the Booking screen
/// Requirements addressed:
/// - Booking System (1.3 Scope/Core Features/Booking System): Supports real-time availability search, booking management, and schedule coordination
class BookingViewModel {
    
    // MARK: - Properties
    
    /// Array of bookings to display
    private(set) var bookings: [Booking] = []
    
    /// Use case for fetching bookings
    private let getBookingsUseCase: GetBookingsUseCase
    
    /// Closure to notify view of state changes
    var onStateChanged: (() -> Void)?
    
    /// Loading state of the view model
    private(set) var isLoading: Bool = false {
        didSet {
            onStateChanged?()
        }
    }
    
    /// Error state of the view model
    private(set) var error: Error? {
        didSet {
            onStateChanged?()
        }
    }
    
    // MARK: - Initialization
    
    /// Initializes the BookingViewModel with required dependencies
    /// - Parameter getBookingsUseCase: Use case for fetching bookings
    init(getBookingsUseCase: GetBookingsUseCase) {
        self.getBookingsUseCase = getBookingsUseCase
        Logger.debug("BookingViewModel initialized")
    }
    
    // MARK: - Public Methods
    
    /// Loads bookings by invoking the GetBookingsUseCase
    func loadBookings() {
        Logger.info("Loading bookings...")
        isLoading = true
        error = nil
        
        getBookingsUseCase.execute { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let bookings):
                Logger.info("Successfully loaded \(bookings.count) bookings")
                self.bookings = bookings
                self.onStateChanged?()
                
            case .failure(let error):
                Logger.error("Failed to load bookings: \(error.localizedDescription)")
                self.error = error
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns the number of bookings available
    var numberOfBookings: Int {
        return bookings.count
    }
    
    /// Returns a booking at the specified index
    /// - Parameter index: Index of the booking to retrieve
    /// - Returns: Booking at the specified index
    func booking(at index: Int) -> Booking? {
        guard index >= 0 && index < bookings.count else {
            Logger.warning("Invalid booking index requested: \(index)")
            return nil
        }
        return bookings[index]
    }
    
    /// Configures a booking cell with data
    /// - Parameters:
    ///   - cell: The cell to configure
    ///   - index: Index of the booking data to use
    func configure(_ cell: BookingCell, at index: Int) {
        guard let booking = booking(at: index) else {
            Logger.warning("Failed to configure cell at index \(index): booking not found")
            return
        }
        
        cell.configure(with: booking)
    }
}

// MARK: - Error Handling

extension BookingViewModel {
    /// Returns whether there is an error state
    var hasError: Bool {
        return error != nil
    }
    
    /// Returns a user-friendly error message
    var errorMessage: String? {
        guard let error = error else { return nil }
        
        if let apiError = error as? APIError {
            return apiError.message
        }
        
        return error.localizedDescription
    }
    
    /// Clears the current error state
    func clearError() {
        error = nil
    }
}

// MARK: - Refresh Control

extension BookingViewModel {
    /// Refreshes the booking data
    /// - Parameter completion: Optional completion handler called when refresh completes
    func refresh(completion: (() -> Void)? = nil) {
        Logger.info("Refreshing bookings...")
        loadBookings()
        completion?()
    }
}