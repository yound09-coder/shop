-- ============================================
--  건강판다 · 슈퍼베이스 주문 표 만들기
--  Supabase 대시보드 → SQL Editor 에 붙여넣고 Run
-- ============================================

-- 1) 주문 표 만들기
create table if not exists public.orders (
  id           bigint generated always as identity primary key,
  created_at   timestamptz not null default now(),
  order_no     text        not null,          -- 주문번호 (예: HP-20260919-4821)
  items        jsonb       not null,          -- 담은 상품 목록
  goods_total  integer     not null,          -- 상품 금액
  ship_fee     integer     not null,          -- 배송비
  total        integer     not null           -- 결제 금액
);

-- 2) 보안 켜기 (이걸 켜야 아래 규칙이 적용됩니다)
alter table public.orders enable row level security;

-- 3) 규칙: 누구나 "주문을 넣는" 것만 가능
--    읽기 규칙은 일부러 만들지 않습니다.
--    → 손님이 다른 사람의 주문을 볼 수 없습니다.
--    → 주문 확인은 대시보드(Table Editor)에서 하시면 됩니다.
drop policy if exists "anyone can place an order" on public.orders;

create policy "anyone can place an order"
  on public.orders
  for insert
  to anon, authenticated
  with check (true);

-- ============================================
--  확인용: 실행 후 대시보드 Table Editor → orders 에서
--  주문이 쌓이는지 볼 수 있습니다.
-- ============================================
