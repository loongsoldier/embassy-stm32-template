#![no_std]
#![no_main]

use defmt_rtt as _;

#[cfg(test)]
#[embedded_test::tests]
mod tests {
    use embassy_time::{Duration, Timer};

    /// Optional: runs before each test, can return state passed to tests.
    #[init]
    async fn init() -> embassy_stm32::Peripherals {
        let p = embassy_stm32::init(Default::default());
        defmt::info!("Test init done");
        p
    }

    /// Basic async test with hardware access.
    #[test]
    async fn timer_works(_p: embassy_stm32::Peripherals) {
        defmt::info!("Running timer test...");
        Timer::after(Duration::from_millis(10)).await;
        assert!(true);
    }

    /// A test that is expected to panic.
    #[test]
    #[should_panic]
    fn expected_panic() {
        panic!("This panic is expected");
    }

    /// An ignored test (skipped by default, run with `cargo test -- --ignored`).
    #[test]
    #[ignore]
    fn ignored() {
        defmt::info!("You won't see this unless you run with --ignored");
    }
}
